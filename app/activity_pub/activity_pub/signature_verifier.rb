require "openssl"
require "base64"

module ActivityPub
  class SignatureVerifier
    attr_reader :remote_actor

    def initialize(request, body)
      @request = request
      @body = body
      @remote_actor = nil
      @verified = nil
    end

    def verified?
      return @verified unless @verified.nil?

      @verified = verify
    end

    private

    def verify
      # Parse Signature header
      sig_params = SignatureHeader.parse(@request.headers["Signature"])
      return false unless sig_params

      # Check Date header clock skew
      date = @request.headers["Date"]
      if date
        request_time = Time.httpdate(date)
        return false if (Time.now.utc - request_time).abs > HttpSignature::CLOCK_SKEW
      end

      # Verify Digest if present
      if @body.present? && @request.headers["Digest"]
        expected_digest = "SHA-256=#{Base64.strict_encode64(OpenSSL::Digest::SHA256.digest(@body))}"
        return false unless @request.headers["Digest"] == expected_digest
      end

      # Fetch the key
      key_id = sig_params[:key_id]
      @remote_actor = KeyFetcher.fetch(key_id)
      return false unless @remote_actor&.public_key_pem

      # Rebuild signing string
      signing_string = build_signing_string(sig_params[:headers])

      # Verify signature
      public_key = OpenSSL::PKey::RSA.new(@remote_actor.public_key_pem)
      signature = Base64.decode64(sig_params[:signature])

      public_key.verify(OpenSSL::Digest.new("SHA256"), signature, signing_string)
    rescue OpenSSL::PKey::PKeyError, ArgumentError, Time::Error
      false
    end

    def build_signing_string(signed_headers_str)
      return "" unless signed_headers_str

      signed_headers_str.split(" ").map do |header_name|
        if header_name == "(request-target)"
          "(request-target): #{@request.method.downcase} #{@request.original_fullpath}"
        elsif header_name == "host"
          "host: #{@request.headers['Host']}"
        elsif header_name == "date"
          "date: #{@request.headers['Date']}"
        elsif header_name == "digest"
          "digest: #{@request.headers['Digest']}"
        elsif header_name == "content-type"
          "content-type: #{@request.headers['Content-Type']}"
        else
          "#{header_name}: #{@request.headers[header_name]}"
        end
      end.join("\n")
    end
  end
end

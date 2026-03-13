require "openssl"
require "base64"

module ActivityPub
  class Signer
    def initialize(private_key:, key_id:)
      @private_key = private_key
      @key_id = key_id
    end

    def sign_request(method:, url:, body: nil, content_type: "application/activity+json")
      uri = URI.parse(url)
      date = Time.now.utc.httpdate
      headers = {}

      headers["Host"] = uri.host
      headers["Date"] = date
      headers["Content-Type"] = content_type if body

      if body
        digest = "SHA-256=#{Base64.strict_encode64(OpenSSL::Digest::SHA256.digest(body))}"
        headers["Digest"] = digest
      end

      signed_headers = if body
        "(request-target) host date digest content-type"
      else
        "(request-target) host date"
      end

      signing_string = build_signing_string(
        method: method.downcase,
        path: uri.request_uri,
        headers: headers,
        signed_headers: signed_headers
      )

      signature = Base64.strict_encode64(
        @private_key.sign(OpenSSL::Digest.new("SHA256"), signing_string)
      )

      headers["Signature"] = SignatureHeader.build(
        key_id: @key_id,
        algorithm: HttpSignature::ALGORITHM,
        headers: signed_headers,
        signature: signature
      )

      headers
    end

    private

    def build_signing_string(method:, path:, headers:, signed_headers:)
      signed_headers.split(" ").map do |header_name|
        if header_name == "(request-target)"
          "(request-target): #{method} #{path}"
        else
          "#{header_name}: #{headers[header_name.split('-').map(&:capitalize).join('-')]}"
        end
      end.join("\n")
    end
  end
end

require "net/http"

module ActivityPub
  class OutboxDelivery
    def initialize(outbound_activity, inbox_url)
      @outbound_activity = outbound_activity
      @inbox_url = inbox_url
    end

    def deliver!
      account = @outbound_activity.account
      signer = Signer.new(private_key: account.private_key, key_id: account.key_id)

      body = @outbound_activity.payload_json
      headers = signer.sign_request(method: "POST", url: @inbox_url, body: body)

      uri = URI.parse(@inbox_url)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 30) do |http|
        request = Net::HTTP::Post.new(uri.request_uri)
        headers.each { |k, v| request[k] = v }
        request.body = body
        http.request(request)
      end

      success = response.code.to_i.between?(200, 299)

      DeliveryAttempt.create!(
        outbound_activity: @outbound_activity,
        inbox_url: @inbox_url,
        response_status: response.code.to_i,
        response_body: response.body&.truncate(1000),
        success: success
      )

      success
    rescue StandardError => e
      DeliveryAttempt.create!(
        outbound_activity: @outbound_activity,
        inbox_url: @inbox_url,
        success: false,
        error_message: e.message
      )

      false
    end
  end
end

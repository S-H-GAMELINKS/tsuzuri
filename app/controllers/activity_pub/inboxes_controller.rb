module ActivityPub
  class InboxesController < BaseController
    before_action :set_account

    def create
      body = request.body.read
      json = JSON.parse(body)

      # Verify HTTP Signature
      verification = SignatureVerifier.new(request, body)
      unless verification.verified?
        return head :unauthorized
      end

      activity_type = json["type"]
      activity_id = json["id"]

      inbound = InboundActivity.create!(
        remote_actor: verification.remote_actor,
        activity_id: activity_id,
        activity_type: activity_type,
        raw_json: body,
        signature_verified: true
      )

      ProcessInboundActivityJob.perform_later(inbound.id)

      head :accepted
    rescue JSON::ParserError
      head :bad_request
    end
  end
end

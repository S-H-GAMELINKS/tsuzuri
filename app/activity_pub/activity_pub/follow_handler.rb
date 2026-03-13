module ActivityPub
  class FollowHandler
    def initialize(inbound_activity, parser)
      @inbound_activity = inbound_activity
      @parser = parser
    end

    def handle!
      account = Account.first
      remote_actor = @inbound_activity.remote_actor

      unless remote_actor
        @inbound_activity.mark_failed!("No remote actor associated")
        return
      end

      # Create or reactivate follower (idempotent)
      follower = Follower.find_or_initialize_by(follow_activity_id: @parser.activity_id)
      follower.assign_attributes(
        remote_actor: remote_actor,
        account: account,
        state: "active",
        undone_at: nil
      )
      follower.save!

      # Generate Accept activity
      accept = AcceptActivity.new(
        account: account,
        follow_activity: @parser.object.is_a?(Hash) ? @parser.object : { "id" => @parser.activity_id, "type" => "Follow", "actor" => @parser.actor, "object" => account.activity_pub_url }
      )

      accept_hash = accept.to_h
      outbound = OutboundActivity.create!(
        account: account,
        activity_type: "Accept",
        activity_uri: accept_hash[:id],
        payload_json: accept_hash.to_json,
        status: "pending"
      )

      DeliverActivityJob.perform_later(outbound.id, remote_actor.inbox_url)

      @inbound_activity.mark_processed!
    end
  end
end

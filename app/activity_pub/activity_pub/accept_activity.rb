module ActivityPub
  class AcceptActivity
    CONTEXT = "https://www.w3.org/ns/activitystreams"

    def initialize(account:, follow_activity:)
      @account = account
      @follow_activity = follow_activity
    end

    def to_h
      {
        "@context": CONTEXT,
        id: "#{@account.activity_pub_url}#accept-#{SecureRandom.hex(8)}",
        type: "Accept",
        actor: @account.activity_pub_url,
        object: @follow_activity
      }
    end

    def to_json(*)
      to_h.to_json(*)
    end
  end
end

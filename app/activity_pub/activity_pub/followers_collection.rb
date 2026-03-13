module ActivityPub
  class FollowersCollection
    CONTEXT = "https://www.w3.org/ns/activitystreams"

    def initialize(account)
      @account = account
    end

    def to_h
      active_followers = @account.followers.active.includes(:remote_actor)
      {
        "@context": CONTEXT,
        id: "#{@account.activity_pub_url}/followers",
        type: "OrderedCollection",
        totalItems: active_followers.count,
        orderedItems: active_followers.map { |f| f.remote_actor.actor_uri }
      }
    end

    def to_json(*)
      to_h.to_json(*)
    end
  end
end

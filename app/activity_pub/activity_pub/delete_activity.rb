module ActivityPub
  class DeleteActivity
    CONTEXT = "https://www.w3.org/ns/activitystreams"
    PUBLIC = "https://www.w3.org/ns/activitystreams#Public"

    # For post deletion
    def self.for_post(post)
      new(
        actor_url: post.account.activity_pub_url,
        activity_uri: post.activity_pub_delete_activity_uri,
        object_uri: post.activity_pub_object_uri,
        object_type: "Tombstone",
        followers_url: "#{post.account.activity_pub_url}/followers"
      )
    end

    # For actor deletion (self-destruct)
    def self.for_actor(account)
      new(
        actor_url: account.activity_pub_url,
        activity_uri: "#{account.activity_pub_url}#delete",
        object_uri: account.activity_pub_url,
        object_type: nil,
        followers_url: "#{account.activity_pub_url}/followers"
      )
    end

    def initialize(actor_url:, activity_uri:, object_uri:, object_type:, followers_url:)
      @actor_url = actor_url
      @activity_uri = activity_uri
      @object_uri = object_uri
      @object_type = object_type
      @followers_url = followers_url
    end

    def to_h
      object = if @object_type == "Tombstone"
        { id: @object_uri, type: "Tombstone" }
      else
        @object_uri
      end

      {
        "@context": CONTEXT,
        id: @activity_uri,
        type: "Delete",
        actor: @actor_url,
        to: [ PUBLIC ],
        cc: [ @followers_url ],
        object: object
      }
    end

    def to_json(*)
      to_h.to_json(*)
    end
  end
end

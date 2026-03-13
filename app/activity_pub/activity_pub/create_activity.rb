module ActivityPub
  class CreateActivity
    CONTEXT = "https://www.w3.org/ns/activitystreams"
    PUBLIC = "https://www.w3.org/ns/activitystreams#Public"

    def initialize(post)
      @post = post
      @account = post.account
    end

    def to_h
      {
        "@context": CONTEXT,
        id: @post.activity_pub_create_activity_uri,
        type: "Create",
        actor: @account.activity_pub_url,
        published: @post.published_at&.iso8601,
        to: [ PUBLIC ],
        cc: [ "#{@account.activity_pub_url}/followers" ],
        object: ActivityPub::Note.new(@post).to_h.except(:"@context")
      }
    end

    def to_json(*)
      to_h.to_json(*)
    end
  end
end

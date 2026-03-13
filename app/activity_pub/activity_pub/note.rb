module ActivityPub
  class Note
    CONTEXT = "https://www.w3.org/ns/activitystreams"
    PUBLIC = "https://www.w3.org/ns/activitystreams#Public"

    def initialize(post)
      @post = post
      @account = post.account
    end

    def to_h
      {
        "@context": CONTEXT,
        id: @post.activity_pub_object_uri,
        type: "Note",
        attributedTo: @account.activity_pub_url,
        content: @post.html_body,
        published: @post.published_at&.iso8601,
        url: @post.activity_pub_object_uri,
        to: [ PUBLIC ],
        cc: [ "#{@account.activity_pub_url}/followers" ]
      }
    end

    def to_json(*)
      to_h.to_json(*)
    end
  end
end

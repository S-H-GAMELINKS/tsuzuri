module ActivityPub
  class Outbox
    CONTEXT = "https://www.w3.org/ns/activitystreams"

    def initialize(account)
      @account = account
    end

    def to_h
      published_posts = @account.posts.published.newest_first
      {
        "@context": CONTEXT,
        id: "#{@account.activity_pub_url}/outbox",
        type: "OrderedCollection",
        totalItems: published_posts.count,
        orderedItems: published_posts.map { |post| ActivityPub::CreateActivity.new(post).to_h.except(:"@context") }
      }
    end

    def to_json(*)
      to_h.to_json(*)
    end
  end
end

module ActivityPub
  class WebfingerResource
    def initialize(account)
      @account = account
    end

    def to_h
      {
        subject: "acct:#{@account.username}@#{Tsuzuri.domain}",
        aliases: [ @account.activity_pub_url ],
        links: [
          {
            rel: "self",
            type: "application/activity+json",
            href: @account.activity_pub_url
          },
          {
            rel: "http://webfinger.net/rel/profile-page",
            type: "text/html",
            href: @account.activity_pub_url
          }
        ]
      }
    end

    def to_json(*)
      to_h.to_json(*)
    end
  end
end

module ActivityPub
  class Actor
    CONTEXT = [
      "https://www.w3.org/ns/activitystreams",
      "https://w3id.org/security/v1"
    ].freeze

    def initialize(account)
      @account = account
    end

    def to_h
      {
        "@context": CONTEXT,
        id: @account.activity_pub_url,
        type: "Person",
        preferredUsername: @account.username,
        name: @account.display_name,
        summary: @account.summary,
        inbox: "#{@account.activity_pub_url}/inbox",
        outbox: "#{@account.activity_pub_url}/outbox",
        followers: "#{@account.activity_pub_url}/followers",
        url: @account.activity_pub_url,
        publicKey: {
          id: @account.key_id,
          owner: @account.activity_pub_url,
          publicKeyPem: @account.public_key_pem
        }
      }
    end

    def to_json(*)
      to_h.to_json(*)
    end
  end
end

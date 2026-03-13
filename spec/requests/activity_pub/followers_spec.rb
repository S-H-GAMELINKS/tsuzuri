require "rails_helper"

RSpec.describe "ActivityPub Followers", type: :request do
  let!(:account) { create(:account, username: "me") }

  describe "GET /users/:username/followers" do
    it "returns OrderedCollection" do
      remote = create(:remote_actor)
      create(:follower, remote_actor: remote, account: account)

      get activity_pub_followers_path(username: "me")
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["type"]).to eq("OrderedCollection")
      expect(json["totalItems"]).to eq(1)
      expect(json["orderedItems"]).to include(remote.actor_uri)
    end

    it "excludes undone followers" do
      remote = create(:remote_actor)
      create(:follower, remote_actor: remote, account: account, state: "undone")

      get activity_pub_followers_path(username: "me")
      json = JSON.parse(response.body)
      expect(json["totalItems"]).to eq(0)
    end
  end
end

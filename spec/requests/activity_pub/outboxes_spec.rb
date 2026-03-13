require "rails_helper"

RSpec.describe "ActivityPub Outboxes", type: :request do
  let!(:account) { create(:account, username: "me") }

  describe "GET /users/:username/outbox" do
    it "returns OrderedCollection" do
      create(:post, :published, account: account)
      get activity_pub_outbox_path(username: "me")
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["type"]).to eq("OrderedCollection")
      expect(json["totalItems"]).to eq(1)
      expect(json["orderedItems"].first["type"]).to eq("Create")
    end

    it "excludes drafts" do
      create(:post, account: account)
      get activity_pub_outbox_path(username: "me")
      json = JSON.parse(response.body)
      expect(json["totalItems"]).to eq(0)
    end
  end
end

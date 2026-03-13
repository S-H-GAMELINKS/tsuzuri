require "rails_helper"

RSpec.describe "ActivityPub Actors", type: :request do
  let!(:account) { create(:account, username: "me") }

  describe "GET /users/:username" do
    it "returns Actor JSON" do
      get activity_pub_actor_path(username: "me")
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/activity+json")

      json = JSON.parse(response.body)
      expect(json["type"]).to eq("Person")
      expect(json["preferredUsername"]).to eq("me")
      expect(json["inbox"]).to eq("#{account.activity_pub_url}/inbox")
      expect(json["outbox"]).to eq("#{account.activity_pub_url}/outbox")
      expect(json["publicKey"]["id"]).to eq(account.key_id)
      expect(json["publicKey"]["publicKeyPem"]).to eq(account.public_key_pem)
    end

    it "returns 404 for unknown username" do
      get activity_pub_actor_path(username: "nobody")
      expect(response).to have_http_status(:not_found)
    end
  end
end

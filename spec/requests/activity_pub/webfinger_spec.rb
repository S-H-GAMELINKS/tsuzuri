require "rails_helper"

RSpec.describe "WebFinger", type: :request do
  let!(:account) { create(:account, username: "me") }

  describe "GET /.well-known/webfinger" do
    it "returns JRD for valid acct" do
      get "/.well-known/webfinger", params: { resource: "acct:me@#{Tsuzuri.domain}" }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/jrd+json")

      json = JSON.parse(response.body)
      expect(json["subject"]).to eq("acct:me@#{Tsuzuri.domain}")
      expect(json["links"].first["href"]).to eq(account.activity_pub_url)
    end

    it "returns 404 for unknown user" do
      get "/.well-known/webfinger", params: { resource: "acct:nobody@#{Tsuzuri.domain}" }
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for wrong domain" do
      get "/.well-known/webfinger", params: { resource: "acct:me@wrong.example" }
      expect(response).to have_http_status(:not_found)
    end

    it "returns 400 without acct: prefix" do
      get "/.well-known/webfinger", params: { resource: "me@#{Tsuzuri.domain}" }
      expect(response).to have_http_status(:bad_request)
    end
  end
end

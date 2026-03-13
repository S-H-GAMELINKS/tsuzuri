require "rails_helper"

RSpec.describe "Posts", type: :request do
  let!(:account) { create(:account, username: "me") }

  describe "GET /posts" do
    it "returns HTML listing" do
      create(:post, :published, account: account, title: "Hello World")
      get posts_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Hello World")
    end

    it "does not show draft posts" do
      create(:post, account: account, title: "Secret Draft")
      get posts_path
      expect(response.body).not_to include("Secret Draft")
    end
  end

  describe "GET /posts/:id" do
    let!(:post_record) { create(:post, :published, account: account, title: "Test Post", slug: "test-post") }

    it "returns HTML by default" do
      get post_path(post_record)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Test Post")
      expect(response.body).to include("fediverse:creator")
    end

    it "returns activity+json when requested" do
      get post_path(post_record), headers: { "Accept" => "application/activity+json" }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/activity+json")
      json = JSON.parse(response.body)
      expect(json["type"]).to eq("Note")
      expect(json["attributedTo"]).to eq(account.activity_pub_url)
    end

    it "returns 404 for nonexistent post" do
      get "/posts/0"
      expect(response).to have_http_status(:not_found)
    end
  end
end

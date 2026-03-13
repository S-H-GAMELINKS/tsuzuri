require "rails_helper"

RSpec.describe "Admin Posts", type: :request do
  let!(:account) { create(:account, username: "me") }

  before do
    post "/login", params: { email: account.email, password: "password123" }
  end

  describe "GET /admin/posts" do
    it "lists posts" do
      create(:post, account: account, title: "My Post")
      get admin_posts_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("My Post")
    end
  end

  describe "POST /admin/posts" do
    it "creates a draft post" do
      post admin_posts_path, params: { post: { title: "New Post", plaintext_body: "Body text" } }
      expect(response).to have_http_status(:redirect)
      expect(Post.last.title).to eq("New Post")
      expect(Post.last.state).to eq("draft")
    end
  end

  describe "POST /admin/posts/:id/publish" do
    it "publishes and enqueues fanout" do
      post_record = create(:post, account: account, title: "Draft")
      post admin_publish_post_path(post_record)
      expect(response).to have_http_status(:redirect)
      expect(post_record.reload.state).to eq("published")
      expect(FanoutPostDeliveryJob).to have_been_enqueued.with(post_record.id)
    end
  end

  describe "POST /admin/posts/:id/delete_post" do
    it "marks deleted and enqueues delete fanout" do
      post_record = create(:post, :published, account: account)
      post admin_delete_post_activity_path(post_record)
      expect(response).to have_http_status(:redirect)
      expect(post_record.reload.state).to eq("deleted")
      expect(FanoutDeleteDeliveryJob).to have_been_enqueued.with(post_record.id)
    end
  end
end

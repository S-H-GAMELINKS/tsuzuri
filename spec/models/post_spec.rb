require "rails_helper"

RSpec.describe Post, type: :model do
  let(:account) { create(:account) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:plaintext_body) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to belong_to(:account) }
  end

  describe "slug generation" do
    it "auto-generates slug from title" do
      post = create(:post, account: account, title: "Hello World")
      expect(post.slug).to eq("hello-world")
    end

    it "generates unique slugs" do
      create(:post, account: account, title: "Hello World")
      post2 = create(:post, account: account, title: "Hello World")
      expect(post2.slug).to eq("hello-world-2")
    end
  end

  describe "HTML generation" do
    it "converts plaintext to HTML" do
      post = create(:post, account: account, title: "Test", plaintext_body: "First paragraph\n\nSecond paragraph")
      expect(post.html_body).to include("<p>First paragraph</p>")
      expect(post.html_body).to include("<p>Second paragraph</p>")
    end

    it "escapes HTML in plaintext" do
      post = create(:post, account: account, title: "Test", plaintext_body: "<script>alert('xss')</script>")
      expect(post.html_body).not_to include("<script>")
      expect(post.html_body).to include("&lt;script&gt;")
    end
  end

  describe "#publish!" do
    it "transitions to published state" do
      post = create(:post, account: account)
      post.publish!
      expect(post.state).to eq("published")
      expect(post.published_at).to be_present
      expect(post.activity_pub_object_uri).to be_present
      expect(post.activity_pub_create_activity_uri).to be_present
    end
  end

  describe "#mark_deleted!" do
    it "transitions to deleted state" do
      post = create(:post, :published, account: account)
      post.mark_deleted!
      expect(post.state).to eq("deleted")
      expect(post.activity_pub_delete_activity_uri).to be_present
    end
  end

end

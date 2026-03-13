require "rails_helper"

RSpec.describe ActivityPub::InboxHandler, type: :model do
  let!(:account) { create(:account, username: "me") }
  let!(:remote_actor) { create(:remote_actor, actor_uri: "https://remote.example/users/alice") }

  describe "Follow handling" do
    it "creates a follower and enqueues Accept" do
      follow_json = {
        "id" => "https://remote.example/activities/follow/1",
        "type" => "Follow",
        "actor" => "https://remote.example/users/alice",
        "object" => account.activity_pub_url
      }.to_json

      inbound = create(:inbound_activity,
        remote_actor: remote_actor,
        activity_type: "Follow",
        raw_json: follow_json
      )

      expect {
        described_class.new(inbound).process!
      }.to have_enqueued_job(DeliverActivityJob)

      expect(Follower.count).to eq(1)
      expect(Follower.last.state).to eq("active")
      expect(inbound.reload.status).to eq("processed")
    end

    it "is idempotent for duplicate follows" do
      follow_json = {
        "id" => "https://remote.example/activities/follow/1",
        "type" => "Follow",
        "actor" => "https://remote.example/users/alice",
        "object" => account.activity_pub_url
      }.to_json

      inbound1 = create(:inbound_activity, remote_actor: remote_actor, activity_type: "Follow", raw_json: follow_json)
      inbound2 = create(:inbound_activity, remote_actor: remote_actor, activity_type: "Follow", raw_json: follow_json)

      described_class.new(inbound1).process!
      described_class.new(inbound2).process!

      expect(Follower.count).to eq(1)
    end
  end

  describe "Undo(Follow) handling" do
    it "marks follower as undone" do
      create(:follower,
        remote_actor: remote_actor,
        account: account,
        follow_activity_id: "https://remote.example/activities/follow/1"
      )

      undo_json = {
        "id" => "https://remote.example/activities/undo/1",
        "type" => "Undo",
        "actor" => "https://remote.example/users/alice",
        "object" => {
          "id" => "https://remote.example/activities/follow/1",
          "type" => "Follow",
          "actor" => "https://remote.example/users/alice",
          "object" => account.activity_pub_url
        }
      }.to_json

      inbound = create(:inbound_activity, remote_actor: remote_actor, activity_type: "Undo", raw_json: undo_json)
      described_class.new(inbound).process!

      expect(Follower.last.state).to eq("undone")
      expect(inbound.reload.status).to eq("processed")
    end
  end

  describe "unsupported activities" do
    it "rejects unsupported types" do
      like_json = {
        "type" => "Like",
        "actor" => "https://remote.example/users/alice",
        "object" => "https://example.com/posts/1"
      }.to_json

      inbound = create(:inbound_activity, remote_actor: remote_actor, activity_type: "Like", raw_json: like_json)
      described_class.new(inbound).process!

      expect(inbound.reload.status).to eq("rejected")
    end
  end
end

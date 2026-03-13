require "rails_helper"

RSpec.describe "ActivityPub Inboxes", type: :request do
  let!(:account) { create(:account, username: "me") }
  let(:remote_key) { OpenSSL::PKey::RSA.generate(2048) }
  let!(:remote_actor) do
    create(:remote_actor,
      actor_uri: "https://remote.example/users/alice",
      inbox_url: "https://remote.example/users/alice/inbox",
      public_key_pem: remote_key.public_key.to_pem,
      public_key_id: "https://remote.example/users/alice#main-key",
      domain: "remote.example"
    )
  end

  let(:follow_activity) do
    {
      "@context" => "https://www.w3.org/ns/activitystreams",
      "id" => "https://remote.example/activities/follow/1",
      "type" => "Follow",
      "actor" => "https://remote.example/users/alice",
      "object" => account.activity_pub_url
    }
  end

  def signed_post(body_hash)
    body = body_hash.to_json
    url = activity_pub_inbox_url(username: "me")
    headers = sign_request(
      method: "POST",
      url: url,
      body: body,
      private_key: remote_key,
      key_id: "https://remote.example/users/alice#main-key"
    )
    post url, params: body, headers: headers.merge("Content-Type" => "application/activity+json")
  end

  describe "POST /users/:username/inbox" do
    context "Follow" do
      it "accepts and enqueues processing" do
        signed_post(follow_activity)
        expect(response).to have_http_status(:accepted)
        expect(InboundActivity.count).to eq(1)
        expect(InboundActivity.last.activity_type).to eq("Follow")
      end
    end

    context "Undo Follow" do
      it "accepts Undo(Follow)" do
        create(:follower,
          remote_actor: remote_actor,
          account: account,
          follow_activity_id: "https://remote.example/activities/follow/1"
        )

        undo_activity = {
          "@context" => "https://www.w3.org/ns/activitystreams",
          "id" => "https://remote.example/activities/undo/1",
          "type" => "Undo",
          "actor" => "https://remote.example/users/alice",
          "object" => follow_activity
        }

        signed_post(undo_activity)
        expect(response).to have_http_status(:accepted)
      end
    end

    context "without valid signature" do
      it "returns 401" do
        post activity_pub_inbox_path(username: "me"),
          params: follow_activity.to_json,
          headers: { "Content-Type" => "application/activity+json" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

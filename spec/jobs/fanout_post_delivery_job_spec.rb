require "rails_helper"

RSpec.describe FanoutPostDeliveryJob, type: :job do
  let!(:account) { create(:account, username: "me") }
  let!(:post_record) { create(:post, :published, account: account) }

  it "creates OutboundActivity and enqueues delivery" do
    remote = create(:remote_actor)
    create(:follower, remote_actor: remote, account: account)

    expect {
      described_class.perform_now(post_record.id)
    }.to have_enqueued_job(DeliverActivityJob)

    expect(OutboundActivity.count).to eq(1)
    expect(OutboundActivity.last.activity_type).to eq("Create")
  end

  it "deduplicates shared inboxes" do
    remote1 = create(:remote_actor, shared_inbox_url: "https://shared.example/inbox")
    remote2 = create(:remote_actor, shared_inbox_url: "https://shared.example/inbox")
    create(:follower, remote_actor: remote1, account: account)
    create(:follower, remote_actor: remote2, account: account)

    expect {
      described_class.perform_now(post_record.id)
    }.to have_enqueued_job(DeliverActivityJob).exactly(:once)
  end
end

class FanoutPostDeliveryJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find(post_id)
    account = post.account

    create_activity = ActivityPub::CreateActivity.new(post)
    create_hash = create_activity.to_h

    outbound = OutboundActivity.create!(
      post: post,
      account: account,
      activity_type: "Create",
      activity_uri: post.activity_pub_create_activity_uri,
      payload_json: create_hash.to_json,
      status: "pending"
    )

    deliver_to_followers(outbound, account)
  end

  private

  def deliver_to_followers(outbound, account)
    inbox_urls = collect_inbox_urls(account)
    inbox_urls.each do |inbox_url|
      DeliverActivityJob.perform_later(outbound.id, inbox_url)
    end
  end

  def collect_inbox_urls(account)
    # Prefer shared inbox to avoid duplicate deliveries
    inboxes = Set.new
    shared_inboxes = Set.new

    account.followers.active.includes(:remote_actor).find_each do |follower|
      actor = follower.remote_actor
      if actor.shared_inbox_url.present?
        shared_inboxes << actor.shared_inbox_url
      else
        inboxes << actor.inbox_url
      end
    end

    (shared_inboxes + inboxes).to_a
  end
end

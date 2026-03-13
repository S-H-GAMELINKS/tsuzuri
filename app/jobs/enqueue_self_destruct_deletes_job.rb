class EnqueueSelfDestructDeletesJob < ApplicationJob
  queue_as :default

  def perform(run_id)
    run = SelfDestructRun.find(run_id)
    account = Account.first

    total = 0

    # Delete all published posts
    Post.published.find_each do |post|
      post.mark_deleted!
      FanoutDeleteDeliveryJob.perform_later(post.id)
      total += 1
    end

    # Delete Actor itself
    actor_delete = ActivityPub::DeleteActivity.for_actor(account)
    actor_delete_hash = actor_delete.to_h

    outbound = OutboundActivity.create!(
      account: account,
      activity_type: "Delete",
      activity_uri: actor_delete_hash[:id],
      payload_json: actor_delete_hash.to_json,
      status: "pending"
    )

    # Fan out Actor Delete to all known servers
    inbox_urls = collect_all_inbox_urls(account)
    inbox_urls.each do |inbox_url|
      DeliverActivityJob.perform_later(outbound.id, inbox_url)
    end
    total += 1

    run.update!(total_activities: total)
    run.drain!

    FinalizeSelfDestructJob.perform_later(run.id)
  end

  private

  def collect_all_inbox_urls(account)
    inboxes = Set.new

    # From followers
    account.followers.active.includes(:remote_actor).find_each do |follower|
      actor = follower.remote_actor
      inboxes << (actor.shared_inbox_url || actor.inbox_url)
    end

    # From known servers
    KnownServer.reachable.find_each do |server|
      inboxes << server.shared_inbox_url if server.shared_inbox_url.present?
    end

    inboxes.to_a
  end
end

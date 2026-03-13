class ProcessInboundActivityJob < ApplicationJob
  queue_as :default

  def perform(inbound_activity_id)
    inbound = InboundActivity.find(inbound_activity_id)
    ActivityPub::InboxHandler.new(inbound).process!
  end
end

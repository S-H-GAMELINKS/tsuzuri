class DeliverActivityJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(outbound_activity_id, inbox_url)
    outbound = OutboundActivity.find(outbound_activity_id)
    outbound.mark_delivering!

    success = ActivityPub::OutboxDelivery.new(outbound, inbox_url).deliver!

    if success
      outbound.mark_delivered!
    else
      raise "Delivery failed to #{inbox_url}" if executions < 5
      outbound.mark_failed!
    end
  end
end

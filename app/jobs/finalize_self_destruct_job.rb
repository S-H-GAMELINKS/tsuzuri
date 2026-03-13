class FinalizeSelfDestructJob < ApplicationJob
  queue_as :default

  def perform(run_id)
    run = SelfDestructRun.find(run_id)

    # Count delivered and failed
    delivered = OutboundActivity.where(status: "delivered").count
    failed = OutboundActivity.where(status: "failed").count
    run.update!(delivered_activities: delivered, failed_activities: failed)

    progress = Tsuzuri::SelfDestructProgress.new(run)

    if progress.complete?
      run.complete!
    else
      # Re-check in 30 seconds
      FinalizeSelfDestructJob.set(wait: 30.seconds).perform_later(run_id)
    end
  end
end

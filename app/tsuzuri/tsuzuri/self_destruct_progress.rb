module Tsuzuri
  class SelfDestructProgress
    def initialize(run)
      @run = run
    end

    def percentage
      @run.progress_percentage
    end

    def complete?
      return false if @run.total_activities.zero?

      (@run.delivered_activities + @run.failed_activities) >= @run.total_activities
    end

    def summary
      {
        state: @run.state,
        total: @run.total_activities,
        delivered: @run.delivered_activities,
        failed: @run.failed_activities,
        percentage: percentage,
        complete: complete?
      }
    end
  end
end

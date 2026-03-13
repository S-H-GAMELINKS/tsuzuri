module Tsuzuri
  class SelfDestructRunner
    def initialize(run)
      @run = run
    end

    def execute!
      @run.start!
      EnqueueSelfDestructDeletesJob.perform_later(@run.id)
    end
  end
end

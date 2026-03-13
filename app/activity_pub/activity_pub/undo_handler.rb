module ActivityPub
  class UndoHandler
    def initialize(inbound_activity, parser)
      @inbound_activity = inbound_activity
      @parser = parser
    end

    def handle!
      follow_object = @parser.object
      follow_id = follow_object.is_a?(Hash) ? follow_object["id"] : follow_object

      follower = Follower.find_by(follow_activity_id: follow_id)

      if follower
        follower.undo!
        @inbound_activity.mark_processed!
      else
        @inbound_activity.mark_rejected!("Follow activity not found: #{follow_id}")
      end
    end
  end
end

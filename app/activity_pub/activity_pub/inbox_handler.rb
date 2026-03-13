module ActivityPub
  class InboxHandler
    def initialize(inbound_activity)
      @inbound_activity = inbound_activity
      @parser = InboxParser.new(inbound_activity.raw_json)
    end

    def process!
      unless @parser.supported?
        @inbound_activity.mark_rejected!("Unsupported activity type: #{@parser.activity_type}")
        return
      end

      if @parser.follow?
        FollowHandler.new(@inbound_activity, @parser).handle!
      elsif @parser.undo_follow?
        UndoHandler.new(@inbound_activity, @parser).handle!
      else
        @inbound_activity.mark_rejected!("Unsupported Undo object type")
      end
    rescue StandardError => e
      @inbound_activity.mark_failed!(e.message)
      raise
    end
  end
end

module ActivityPub
  class InboxParser
    SUPPORTED_TYPES = %w[Follow Undo].freeze

    def initialize(json)
      @json = json.is_a?(String) ? JSON.parse(json) : json
    end

    def activity_type
      @json["type"]
    end

    def supported?
      SUPPORTED_TYPES.include?(activity_type)
    end

    def follow?
      activity_type == "Follow"
    end

    def undo?
      activity_type == "Undo"
    end

    def undo_follow?
      undo? && object_type == "Follow"
    end

    def actor
      @json["actor"]
    end

    def object
      @json["object"]
    end

    def activity_id
      @json["id"]
    end

    private

    def object_type
      case object
      when Hash then object["type"]
      when String then nil
      end
    end
  end
end

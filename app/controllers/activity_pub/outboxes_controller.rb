module ActivityPub
  class OutboxesController < BaseController
    before_action :set_account

    def show
      activity_json_response(Outbox.new(@account))
    end
  end
end

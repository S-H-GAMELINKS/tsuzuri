module Admin
  class InboundActivitiesController < BaseController
    def index
      @inbound_activities = InboundActivity.order(created_at: :desc).limit(100)
    end

    def show
      @inbound_activity = InboundActivity.find(params[:id])
    end
  end
end

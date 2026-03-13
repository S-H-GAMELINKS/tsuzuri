module ActivityPub
  class ActorsController < BaseController
    before_action :set_account

    def show
      activity_json_response(Actor.new(@account))
    end
  end
end

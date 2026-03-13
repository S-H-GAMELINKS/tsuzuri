module ActivityPub
  class FollowersController < BaseController
    before_action :set_account

    def show
      activity_json_response(FollowersCollection.new(@account))
    end
  end
end

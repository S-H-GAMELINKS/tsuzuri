module ActivityPub
  class BaseController < ApplicationController
    skip_forgery_protection

    private

    def set_account
      @account = Account.find_by!(username: params[:username])
    end

    def activity_json_response(data)
      render json: data.to_h, content_type: "application/activity+json"
    end
  end
end

module Admin
  class BaseController < ApplicationController
    before_action :require_authentication

    private

    def require_authentication
      unless rodauth.logged_in?
        redirect_to rodauth.login_path
      end
    end

    def current_account
      @current_account ||= Account.find(rodauth.session_value)
    end
    helper_method :current_account
  end
end

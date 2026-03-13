module Admin
  class SettingsController < BaseController
    def show
      @account = current_account
    end

    def update
      @account = current_account

      if !@account.username_set? && settings_params[:username].present?
        @account.set_username!(settings_params[:username])
      end

      if @account.update(settings_params.except(:username))
        redirect_to admin_settings_path, notice: "Settings updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def settings_params
      params.require(:account).permit(:username, :display_name, :summary, :fediverse_creator)
    end
  end
end

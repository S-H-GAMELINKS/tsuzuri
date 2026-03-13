module Admin
  class FollowersController < BaseController
    def index
      @followers = Follower.includes(:remote_actor).order(created_at: :desc)
    end

    def destroy
      follower = Follower.find(params[:id])
      follower.undo!
      redirect_to admin_followers_path, notice: "Follower removed."
    end
  end
end

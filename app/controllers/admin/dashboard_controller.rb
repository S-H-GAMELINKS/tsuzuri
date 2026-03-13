module Admin
  class DashboardController < BaseController
    def show
      @account = current_account
      @posts_count = Post.count
      @published_count = Post.published.count
      @followers_count = Follower.active.count
      @pending_activities = InboundActivity.pending.count
      @recent_posts = Post.newest_first.limit(5)
    end
  end
end

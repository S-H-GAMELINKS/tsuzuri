class PostsController < ApplicationController
  def index
    @posts = Post.published.newest_first
    @account = Tsuzuri.account
  end

  def show
    @post = Post.published.find(params[:id])
    @account = @post.account

    respond_to do |format|
      format.html
      format.any(:activity_json, :ld_json) do
        render json: ActivityPub::Note.new(@post).to_h,
               content_type: "application/activity+json"
      end
    end
  end
end

module Admin
  class PostsController < BaseController
    before_action :set_post, only: [ :edit, :update, :destroy, :publish, :delete_post ]

    def index
      @posts = Post.where.not(state: "deleted").newest_first
    end

    def new
      @post = Post.new
    end

    def create
      @post = current_account.posts.build(post_params)
      if @post.save
        redirect_to admin_posts_path, notice: "Post created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @post.update(post_params)
        redirect_to admin_posts_path, notice: "Post updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @post.destroy
      redirect_to admin_posts_path, notice: "Post removed."
    end

    def publish
      @post.publish!
      FanoutPostDeliveryJob.perform_later(@post.id)
      redirect_to admin_posts_path, notice: "Post published and federation started."
    end

    def delete_post
      @post.mark_deleted!
      FanoutDeleteDeliveryJob.perform_later(@post.id)
      redirect_to admin_posts_path, notice: "Post deleted and Delete activity queued."
    end

    private

    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :plaintext_body)
    end
  end
end

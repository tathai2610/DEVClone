class CommentsController < ApplicationController
  # include Pundit::Authorization

  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :authenticate_user!
  before_action :find_comment, only: [:edit, :update, :destroy]

  def new 
    @comment = authorize Comment.new
    @comment.user = current_user

    respond_to do |format| 
      format.html
      format.js 
    end
  end

  def create 
    @comment = authorize Comment.new(comment_params)
    @comment.user = current_user
    @comment.commentable = @commentable
    @comment.save 
    Notification.create(sender: current_user, recipient: @commentable.user, action: "replied", notifiable: @commentable)

    respond_to do |f|
      f.js
    end
  end

  def edit 
    respond_to do |format| 
      format.js
    end
  end

  def update
    @comment.update(comment_params)

    respond_to do |format|
      format.js  
      format.html 
    end

  end

  def destroy
    @comment.destroy

    respond_to do |format| 
      format.html 
      format.js 
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end

  def find_comment
    @comment = Comment.find(params[:id])
    authorize @comment
  end

  # def user_not_authorized
  #   flash[:alert] = "You are not authorized to perform this action."
  #   if params[:post_id]
  #     postt = Post.find(params[:post_id])
  #   else
  #     postt = Comment.find(params[:comment_id]).post
  #   end
  #   other_posts = postt.user.posts.where.not(id: postt.id).where(state: :public)
  #   render template: "posts/show", locals: { post: postt, other_posts: other_posts}
  # end
end

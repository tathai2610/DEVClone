class UsersController < ApplicationController
  def show 
    @user = User.find(params[:id])
    @posts = @user.posts.order("created_at DESC")
    @latest_post = @posts.where(state: :public).first
    @rest_posts = @posts.where(state: :public).drop(1)
    if current_user == @user
      @latest_post = @posts.first
      @rest_posts = @posts.drop(1)
    end
    render "users/profiles/show"
  end

  def update 
    @user = User.find(params[:id])
    @user.update(user_params)
    
    redirect_to @user 
  end

  private 

  def user_params 
    params.require(:user).permit(:bio, :avatar, :first_name,)
  end
end

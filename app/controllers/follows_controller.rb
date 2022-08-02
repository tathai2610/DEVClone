class FollowsController < ApplicationController
  before_action :authenticate_user!

  def create 
    @followee = User.find(params[:user_id])
    authorize Follow.create(follower_id: current_user.id, followee_id: @followee.id)
    Notification.create(sender: current_user, recipient: @followee, action: "followed", notifiable: @followee)
    redirect_to @followee
  end

  def destroy 
    @followee = User.find(params[:user_id])
    authorize Follow.find_by(follower_id: current_user.id, followee_id: @followee.id).destroy
    redirect_to @followee
  end
end

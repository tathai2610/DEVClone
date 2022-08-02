class LikesController < ApplicationController
  before_action :authenticate_user!

  def create 
    @like = current_user.likes.new(likeable: @likeable)
    authorize @like 
    @like.save
    Notification.create(sender: current_user, recipient: @likeable.user, action: "liked", notifiable: @likeable)
    respond_to do |format| 
      format.js
    end
  end

  def destroy 
    @like = current_user.likes.find_by(likeable: @likeable)
    authorize @like 
    @like.destroy
    respond_to do |format| 
      format.js 
    end
  end

end

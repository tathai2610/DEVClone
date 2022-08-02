class LikePolicy < ApplicationPolicy
  def create? 
    user.present? 
  end

  def destroy? 
    true if user.present? && user == like.user 
  end

  private 
  
  def like 
    record
  end
end
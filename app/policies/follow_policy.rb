class FollowPolicy < ApplicationPolicy
  def create? 
    user.present? 
  end

  def destroy? 
    true if user.present? && user == follow.follower
  end

  private 
  
  def follow 
    record
  end
end
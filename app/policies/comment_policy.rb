class CommentPolicy < ApplicationPolicy
  def new?
    user.present?
  end

  def create?
    user.present?
  end

  def update? 
    true if user.present? && user == comment.user
  end

  def destroy? 
    true if user.present? && user == comment.user
  end

  private 

  def comment 
    record 
  end
end
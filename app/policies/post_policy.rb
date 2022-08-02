class PostPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    user.present?
  end

  def show? 
    if !post.public?
      return true if user.present? && (user == post.user || user.has_role?(:admin))
    else 
      return true
    end
    false 
  end

  def edit? 
    true if user.present? && user == post.user && !post.public?
  end

  def update?
    return false if post.public?

    if user.present? 
      if post.draft?
        return true if user == post.user
      elsif post.queued? 
        return true if (user == post.user || user.has_role?(:admin))
      end
    end

    false
  end

  def destroy? 
    true if user.present? && user == post.user
  end

  def queue? 
    ( user.present? && user.has_role?(:admin )) ? true :false
  end

  def drafts? 
    ( user.present? && user.has_role?(:admin )) ? true :false
  end

  def my_posts? 
    true if user.present?
  end

  private
  
  def post 
    record 
  end
end
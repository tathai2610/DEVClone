class Comment < ApplicationRecord
  belongs_to :user
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy 
  belongs_to :commentable, polymorphic: true
  has_many :notifs, as: :notifiable, class_name: "Notification"

  validates :content, presence: true

  after_create :increase_count
  after_destroy :decrease_count

  # def count_child(parent)
  #   if parent.nil? 
  #     return 0
  #   end
  #   len = 0 
  #   parent.each do |child|
  #     if child.comments.any?
  #       len += count_child(child)
  #     end
  #     len += 1
  #   end
  #   len
  # end

  def post 
    parent = commentable
    while parent.is_a? Comment 
      parent = parent.commentable
    end
    parent
  end

  private

  def commit_comment action 
    CommentCommitJob.perform_later id, action
  end

  def increase_count
    if commentable.is_a? Post 
      commentable.increment! :comments_count
    end

    # parent = commentable 
    # while parent.is_a? Comment 
    #   parent = parent.commentable
    # end
    # parent.increment! :comments_count
  end

  def decrease_count
    if commentable.is_a? Post 
      commentable.decrement! :comments_count
    end

    # children = comments.any? ? comments : nil
    # parent = commentable 
    # while parent.is_a? Comment 
    #   parent = parent.commentable
    # end
    # parent.update(comments_count: (parent.comments_count - count_child(children)))
  end
end

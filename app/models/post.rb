class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  has_many :notifs, as: :notifiable, class_name: "Notification"
  has_one_attached :cover
  has_rich_text :body

  # after_create :create_post
  # after_update :update_post
  # before_destroy :destroy_post

  state_machine :state, initial: :draft do 
    state :queued
    state :public

    event :enqueue do 
      transition draft: :queued
    end

    event :publish do
      transition queued: :public 
    end

    event :dequeue do 
      transition queued: :draft 
    end

    event :bribe do 
      transition draft: :public 
    end
  end

  def initialize (state)
    super
  end

  private

  # def create_post
  #   PostCommitJob.perform_later id, "create"
  # end

  # def update_post
  #   PostCommitJob.perform_later id, "update"
  # end

  # def destroy_post
  #   PostCommitJob.perform_later id, "destroy"
  # end

end

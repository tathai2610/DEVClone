class Notification < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  after_commit :notify_user

  private 

  def notify_user
    UserNotificationJob.perform_later id
  end
end

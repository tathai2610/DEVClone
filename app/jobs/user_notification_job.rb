class UserNotificationJob < ApplicationJob
  queue_as :default

  def perform(notif_id)
    notif = Notification.find(notif_id)
    unless notif.sender == notif.recipient
      renderer = renderer_with_signed_in_user(notif.sender)
      notif_html = renderer.render partial: "notifications/notification", locals: {notif: notif}, format: [:html]
      notifiable_type = notif.notifiable.class.to_s
      if ((notif.notifiable.is_a? Post) || (notif.notifiable.is_a? Comment) )
        if notif.action == "replied"
          notifiable_html = renderer.render partial: "comments/comment", locals: {comment: Comment.last, commentable: notif.notifiable }, format: [:html]
        elsif notif.action == "liked"
          if notif.notifiable.is_a? Post
            notifiable_html = renderer.render partial: "likes/new_like_post", locals: {like: Like.last, likeable: notif.notifiable}, format: [:html]
          elsif notif.notifiable.is_a? Comment 
            notifiable_html = renderer.render partial: "likes/new_like_comment", locals: {like: Like.last, likeable: notif.notifiable}, format: [:html]
          end
        end
      end
      ActionCable.server.broadcast "notifications: #{notif.recipient.id}", 
      {notif_html: notif_html, notif_action: notif.action, notifiable_type: notifiable_type, notifiable_id: notif.notifiable.id, notifiable_html: notifiable_html }
    end
  end
end

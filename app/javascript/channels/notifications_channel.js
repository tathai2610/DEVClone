import consumer from "./consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    if ($("#navbar-notif-new").is(":hidden") && $(".navbar-notif-list").is(":hidden")) {
      $("#navbar-notif-new").show()
    }
    if ($(".navbar-empty-notif").length) {
      $(".navbar-empty-notif").remove()
    }
    $(".navbar-notif-list").prepend(data.notif_html)

    if (data.notif_action == "replied" ) {
      if (data.notifiable_type == "Post") {
        let newCommentsCount = parseInt($(".post-comment-count").text()) + 1
        $(".post-comment-count").text(newCommentsCount)
        $(".post-comments-count").text("Comments (" + newCommentsCount + ")")
        $(".post-comments").prepend(data.notifiable_html)
        if ($(".post-comment-count").text() == "1") {
          $(".post-left-comment-icon").addClass("commented")
          $(".post-left-comment i.fa-comment").removeClass("fa-regular")
          $(".post-left-comment i.fa-comment").addClass("fa-solid")
        }
      }
      else if (data.notifiable_type == "Comment") {
        $("#comment-" + data.notifiable_id + " > .comment-interaction").after(data.notifiable_html)
      }
    }
    else if (data.notif_action == "liked") {
      if (data.notifiable_type == "Post") {
        $(".post-like-count").text(parseInt($(".post-like-count").text()) + 1)
      }
      else if (data.notifiable_type == "Comment") {
        let likesCountHolder = $("#comment-" + data.notifiable_id + " .comment-like span")
        likesCountHolder.text(parseInt(likesCountHolder.text()) + 1)
      }
    }
  }
});

import consumer from "./consumer"

consumer.subscriptions.create("PostsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    if (data.action == "create") {
      $("#posts").prepend(data.post_index_html)
      $(".user-show-right").prepend(data.user_show_html)
      $(".user-no-posts span").text(parseInt($(".user-no-posts span").text()) + 1)
    }
    else if (data.action == "destroy") {
      $("#post-"+data.post_id).remove()
      $(".user-no-posts span").text(parseInt($(".user-no-posts span").text()) - 1)
    }
  }
});

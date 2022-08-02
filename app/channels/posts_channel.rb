class PostsChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "post:#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end

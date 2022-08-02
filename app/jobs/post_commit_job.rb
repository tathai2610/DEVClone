class PostCommitJob < ApplicationJob
  queue_as :default

  def perform(post_id, action)
    # Do something later
    if action == "create"
      post = Post.find(post_id)
      renderer = renderer_with_signed_in_user(post.user)
      post_index_html = renderer.render partial: "posts/post", locals: { post: post }
      user_show_html = renderer.render partial: "users/profiles/user_post", locals: { post: post }
      ActionCable.server.broadcast "post:#{post.user_id}", {post_index_html: post_index_html, user_show_html: user_show_html, post_id: post_id, action: action}
    elsif action == "destroy"
      ActionCable.server.broadcast "post:#{post.user_id}", {post_id: post_id, action: action}
    end
  end
end

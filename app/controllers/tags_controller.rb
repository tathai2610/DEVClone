class TagsController < ApplicationController
  def show 
    @tag = Tag.find(params[:id])
    @posts = @tag.posts.where(state: :public).order("created_at DESC")
    @state = "##{@tag.title}"
    @pagy, @posts = pagy(@posts, items: 10)
    render "posts/posts_filtered"
  end
end

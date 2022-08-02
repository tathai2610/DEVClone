class PostsController < ApplicationController
    before_action :set_post, only: [:show, :edit, :update, :destroy]    
    
    def index 
        @posts = Post.where(state: :public).order('created_at DESC').includes(:user, :tags, :likes, :comments)
        authorize @posts
        @pagy, @posts = pagy(@posts, items: 10, link_extra: 'data-remote="true"')
        respond_to do |f|
            f.html 
            f.js
        end
    end

    def show 
        @other_posts = @post.user.posts.where.not(id: @post.id).where(state: :public)
    end

    def new 
        @post = authorize Post.new
        @post.user_id = current_user.id
        @post.save(validate: false)
        redirect_to edit_post_path(@post)     
    end

    # def create
    #     @post = authorize Post.new(post_params)
    #     @post.user = current_user 

    #     if @post.save 
    #         redirect_to @post 
    #     else 
    #         render :new 
    #     end
    # end

    def edit
        if @post.post_tags.present? 
            @tags_other = Tag.all.where.not(id: @post.post_tags.pluck(:tag_id))
            @tags_text = "#" + @post.tags.pluck(:title).join("#")
        else 
            @tags_other = Tag.all
            @tags_text = ""
        end 
    end

    def update 
        @tags = Tag.all
        if @post.tags.any? 
            @tags_other = Tag.all.where.not(id: @post.tags.pluck(:id))
            @tags_text = "#" + @post.tags.pluck(:title).join("#")
        else
            @tags_other = Tag.all
            @tags_text = ""
        end
        tag_titles = @tags.pluck(:title)
        if post_params[:tags].present?
            @post.post_tags.destroy_all
            tag_list = post_params[:tags].split(/#/)
            tag_list.each do |tag| 
                puts tag
                if tag.present? 
                    if !tag_titles.include? tag 
                        @post.tags << Tag.create(title: tag)
                    elsif @post.tags.find_by(title: tag).nil? 
                        @post.tags << Tag.find_by(title: tag)
                    end
                end
            end
        end

        unless @post.public? 
            update_state params[:commit], @post
        else
            flash[:warning] = "Could not receive request"
            render :edit
        end
    end

    def destroy 
        @post.destroy 
        redirect_to root_path 
    end

    def queue 
        @posts = Post.where(state: :queued).order('created_at DESC').includes(:user, :tags, :likes, :comments)
        authorize @posts
        @state = "Queued"
        @pagy, @posts = pagy(@posts, items: 10, link_extra: 'data-remote="true"')
        respond_to do |f|
            f.html { render "posts/posts_filtered" }
            f.js { render "posts/index" }
        end
    end

    def drafts
        @posts = Post.where(state: :draft).order('created_at DESC').includes(:user, :tags, :likes, :comments)
        @state = "Draft"
        authorize @posts
        @pagy, @posts = pagy(@posts, items: 10, link_extra: 'data-remote="true"')
        respond_to do |f|
            f.html { render "posts/posts_filtered" }
            f.js { render "posts/index" }
        end
    end

    def my_posts
        @posts = current_user.posts.order('created_at DESC').includes(:user, :tags, :likes, :comments)
        @state = "My"
        authorize @posts
        @pagy, @posts = pagy(@posts, items: 10, link_extra: 'data-remote="true"')
        respond_to do |f|
            f.html { render "posts/posts_filtered" }
            f.js { render "posts/index" }
        end
    end

    private 

    def set_post 
        @post = Post.find(params[:id])
        authorize @post
    end

    def post_params 
        params.require(:post).permit(:title, :body, :cover, :tags)
    end

    def update_state (commit, post)
        if commit == "Save draft" 
            if post.queued?
                post.dequeue
            end
            post.update(post_params.except(:tags))
            flash[:notice] = "You saved your draft"
            redirect_to post 
        elsif commit == "Publish"
            post.update(post_params.except(:tags))
            if post.draft?
                post.enqueue
            end
            flash[:notice] = "Please wait for an Admin to approve your post"
            redirect_to post 
        elsif commit == "Approve" && post.queued?
            post.publish
            flash[:notice] = "You have approved the post"
            redirect_to post
        end
    end
end

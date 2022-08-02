require 'rails_helper'

RSpec.shared_examples "as a guest" do 
  it "returns 401 Unauthorized response" do 
    subject
    expect(response).to have_http_status "401"
  end

  it "includes unauthorized message" do
    subject
    expect(response.body).to include("You need to sign in or sign up before continuing.")
  end
end

RSpec.shared_context "as a member" do 
  before do 
    @user = create(:user)
    sign_in @user
  end
end

RSpec.shared_examples "like create action" do
  it "creates a new like record" do 
    expect { subject }.to change(Like, :count).by(1)
  end

  it "creates a new notification record" do 
    expect { subject }.to change(Notification, :count).by(1)
  end

  it "returns 200 OK response" do 
    subject
    expect(response).to have_http_status "200"
  end
end

RSpec.shared_examples "like destroy action" do
  it "destroys a like record" do 
    expect { subject }.to change(Like, :count).by(-1)
  end

  it "returns 200 OK response" do 
    subject
    expect(response).to have_http_status "200"
  end
end

RSpec.shared_context "when like a post" do 
  subject { post post_likes_path(new_post.id), params: params, xhr: true }

  let (:params) { { post_id: new_post.id } }
end

RSpec.shared_context "when like a comment" do 
  subject { post comment_likes_path(comment.id), params: params, xhr: true }

  let (:params) { { comment_id: comment.id } }
  let (:comment) { create(:comment, commentable: new_post) }
end

RSpec.shared_context "when dislike a post" do 
  subject { delete post_like_path(new_post.id, like.id), params: params, xhr: true }

  let! (:like) { create(:like, likeable: new_post, user: @user) }
  let (:params) { { post_id: new_post.id, id: like.id } }
end

RSpec.shared_context "when dislike a comment" do 
  subject { delete comment_like_path(comment.id, like.id), params: params, xhr: true }

  let (:params) { { comment_id: comment.id, id: like.id } }
  let (:comment) { create(:comment, commentable: new_post) }
  let! (:like) { create(:like, likeable: comment, user: @user) }
end



RSpec.describe "Likes", type: :request do
  let (:new_post) { create(:post) }

  describe "POST /create" do
    describe "when user is not logged in" do
      context "and likeable is a post" do 
        include_context "when like a post"
        
        it_behaves_like "as a guest"
      end
  
      context "and likeable is a comment" do 
        include_context "when like a comment"
        
        it_behaves_like "as a guest"
      end
    end

    describe "when user is logged in" do 
      include_context "as a member"

      context "and likeable is a post" do 
        include_context "when like a post"
        
        it_behaves_like "like create action"
      end
  
      context "and likeable is a comment" do 
        include_context "when like a comment"
  
        it_behaves_like "like create action"
      end
    end
  end

  describe "DELETE /destroy" do
    describe "when user is not logged in" do
      before { @user = create(:user) }

      context "and likeable is a post" do 
        include_context "when dislike a post"
        
        it_behaves_like "as a guest"
      end
  
      context "and likeable is a comment" do 
        include_context "when dislike a comment"
        
        it_behaves_like "as a guest"
      end
    end

    describe "when user is logged in" do 
      include_context "as a member"

      context "and likeable is a post" do 
        include_context "when dislike a post"
        
        it_behaves_like "like destroy action"
      end
  
      context "and likeable is a comment" do 
        include_context "when dislike a comment"
  
        it_behaves_like "like destroy action"
      end
    end
  end
end
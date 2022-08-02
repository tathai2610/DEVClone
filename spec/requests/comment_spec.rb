require 'rails_helper'

RSpec.shared_examples "authorize redirect response" do 
  it "returns an authorize redirect response" do 
    subject
    expect(response).to be_redirect
  end
end

RSpec.shared_examples "error redirect response" do 
  it "returns a redirect response with error" do 
    subject
    expect(response).to redirect_to new_post
  end
end

RSpec.shared_examples "successful response" do 
  it "renders a successful response" do
    subject
    expect(response).to be_successful
  end
end

RSpec.shared_examples "Comment#create action" do 
  it "creates a comment" do 
    expect { subject }.to change(Comment, :count).by(1)
  end

  it "creates notification" do 
    expect { subject }.to change(Notification, :count).by(1)
  end
end



RSpec.describe "Comments", type: :request do
  let (:user) { create(:user) }
  let (:new_post) { create(:post) }
  let! (:comment) { create(:comment, commentable: new_post, user: user) }
  let! (:comment2) { create(:comment, commentable: comment, user: user) }

  describe "GET /new" do
    describe "when user is not logged in" do 
      context "when commentable is a comment" do 
        subject { get new_comment_comment_path(comment.id), xhr: true }

        it "returns have 401 response" do 
          subject 
          expect(response).to have_http_status("401")
        end
      
        # it "includes unauthorized message" do
        #   get new_comment_comment_path(comment.id), xhr: true
        #   expect(response).to include("You need to sign in or sign up before continuing.")
        # end
      end
    end
    
    describe "when user is logged in" do 
      before { sign_in user }

      context "when commentable is a comment" do   
        subject { get new_comment_comment_path(comment.id), xhr: true }
        
        it_behaves_like "successful response"
      end
    end
  end

  describe "POST /create" do 
    describe "when user is not logged in" do 
      describe "when commentable is a post" do 
        subject { post post_comments_path(new_post.id), params: params, xhr: true }

        context "when comment is valid" do 
          let (:params) { { post_id: new_post.id, comment: { content: Faker::Lorem.paragraph } } }

          it_behaves_like "successful response"
        end

        context "when comment is invalid" do 
          let (:params) { { post_id: new_post.id, comment: { content: "" } } }
          
          it_behaves_like "successful response"
        end
      end

      describe "when commentable is a comment" do 
        subject { post comment_comments_path(comment.id), params: params, xhr: true }

        context "when comment is valid" do 
          let (:params) { { comment_id: comment.id, comment: { content: Faker::Lorem.paragraph } } }

          it_behaves_like "successful response"
        end

        context "when comment is invalid" do 
          let (:params) { { comment_id: comment.id, comment: { content: "" } } }
          
          it_behaves_like "successful response"
        end
      end
    end

    describe "when user is logged in" do 
      before { sign_in user }

      describe "when commentable is a post" do 
        subject { post post_comments_path(new_post.id), params: params, xhr: true }

        context "when comment is valid" do
          let (:params) { { post_id: new_post.id, comment: { content: Faker::Lorem.paragraph } } }

          it_behaves_like "Comment#create action"
          it_behaves_like "successful response"
        end

        context "when comment is invalid" do 
          let (:params) { { post_id: new_post.id, comment: { content: "" } } }

          it_behaves_like "successful response"
        end
      end

      describe "when commentable is a comment" do 
        subject { post comment_comments_path(comment.id), params: params, xhr: true }

        context "when comment is valid" do 
          let (:params) { { comment_id: comment.id, comment: { content: Faker::Lorem.paragraph } } }
          
          it_behaves_like "Comment#create action"
          it_behaves_like "successful response"
        end

        context "when comment is invalid" do 
          let (:params) { { comment_id: comment.id, comment: { content: "" } } }

          it_behaves_like "successful response"
        end
      end
    end
  end

  describe "GET /edit" do 
    before { sign_in user }

    context "when commentable is a post" do 
      subject { get edit_post_comment_path(new_post.id, comment.id), xhr: true }

      it_behaves_like "successful response"
    end

    context "when commentable is a comment" do 
      subject { get edit_comment_comment_path(comment.id, comment2.id), xhr: true }

      it_behaves_like "successful response"
    end
  end

  describe "PUT /update" do
    before { sign_in user } 

    context "when commentable is a post" do 
      subject { put post_comment_path(new_post.id, comment.id), params: params, xhr: true }

      let (:params) { { post_id: new_post.id, id: comment.id, comment: { content: Faker::Lorem.paragraph } } }

      it_behaves_like "successful response"

      it "does not create a comment" do 
        expect { subject }.to change(Comment, :count).by(0)
      end
    end

    context "when commentable is a comment" do 
      subject { put comment_comment_path(comment.id, comment2.id), params: params, xhr: true }

      let (:params) { { comment_id: comment.id, id: comment2.id, comment: { content: Faker::Lorem.paragraph } } }

      it_behaves_like "successful response"

      it "does not create a comment" do 
        expect { subject }.to change(Comment, :count).by(0)
      end
    end
  end

  describe "DELETE /destroy" do 
    before { sign_in user }

    context "when commentable is a post" do 
      subject { delete post_comment_path(new_post.id, comment.id), xhr: true }

      it_behaves_like "successful response"

      it "destroys a comment" do 
        expect { subject }.to change(Comment, :count).by(-2)
      end
    end

    context "when commentable is a comment" do 
      subject { delete comment_comment_path(comment.id, comment2.id), xhr: true }

      it_behaves_like "successful response"

      it "destroys a comment" do 
        expect { subject }.to change(Comment, :count).by(-1)
      end
    end
  end
end

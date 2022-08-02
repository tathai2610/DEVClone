require 'rails_helper'

RSpec.shared_examples "successful response" do 
  it "returns successful response" do 
    subject 
    expect(response).to be_successful
  end
end

RSpec.shared_examples "redirect response" do 
  it "returns redirect response" do 
    subject 
    expect(response).to be_redirect
  end
end

RSpec.shared_examples "change number of posts" do |n|
  it "by #{n}" do  
    expect { subject }.to change(Post, :count).by(n)
  end
end



RSpec.describe "Posts", type: :request do
  # before { sign_in user }

  let (:user) { create(:user) }
  let (:admin) { create(:admin) }
  let (:posts) { create_list(:post, 100) }
  let! (:new_post) { create(:post, user: user) }

  describe "GET /index" do
    subject { get posts_path }

    it_behaves_like "successful response"
  end

  describe "GET /show" do 
    subject { get post_path(new_post.id) }

    describe "when user is guest" do 
      context "when post is draft" do 
        it_behaves_like "redirect response" 
      end
  
      context "when post is queued" do 
        before { new_post.enqueue }

        it_behaves_like "redirect response"
      end

      context "when post is public" do 
        before { new_post.bribe }

        it_behaves_like "successful response" 
      end
    end

    describe "when user is post owner" do 
      before { sign_in user }

      context "when post is draft" do 
        it_behaves_like "successful response" 
      end
  
      context "when post is queued" do 
        before { new_post.enqueue }

        it_behaves_like "successful response" 
      end

      context "when post is queued" do 
        before { new_post.bribe }

        it_behaves_like "successful response" 
      end
    end

    describe "when user is admmin" do 
      before { sign_in admin }

      context "when post is draft" do 
        it_behaves_like "successful response" 
      end
  
      context "when post is queued" do 
        before { new_post.enqueue }

        it_behaves_like "successful response" 
      end

      context "when post is queued" do 
        before { new_post.bribe }

        it_behaves_like "successful response" 
      end
    end
  end

  describe "GET /new" do 
    describe "when user is not logged in" do 
      subject { get new_post_path }

      it_behaves_like "redirect response"

      it_behaves_like "change number of posts", 0
    end

    describe "when user is logged in" do 
      before { sign_in user }

      subject { get new_post_path }

      it_behaves_like "redirect response"    

      it_behaves_like "change number of posts", 1
    end
  end

  describe "GET /edit" do 
    subject { get edit_post_path(new_post) }

    describe "when user is not post owner" do 
      it_behaves_like "redirect response"
      it_behaves_like "change number of posts", 0
    end

    describe "when user is post owner" do 
      before { sign_in user }

      describe "when post is draft" do 
        it_behaves_like "successful response"    
        it_behaves_like "change number of posts", 0
      end 

      describe "when post is queued" do 
        before { new_post.enqueue }

        it_behaves_like "successful response"    
        it_behaves_like "change number of posts", 0
      end

      describe "when post is public" do 
        before { new_post.bribe }

        it_behaves_like "redirect response" 
        it_behaves_like "change number of posts", 0
      end
    end

    describe "when user is admin" do 
      before { sign_in admin }

      it_behaves_like "redirect response"   
      it_behaves_like "change number of posts", 0
    end
  end

  describe "PUT /update" do 
    subject { put post_path(new_post), params: params }

    describe "when user is guest" do 
      let(:params) { { post: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph } } }

      it_behaves_like "redirect response"
    end

    describe "when user is post owner" do 
      before { sign_in user }

      describe "when post is draft" do 
        context "when user updates post attributes" do 
          let(:params) { { commit: "Save draft", post: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph } } }

          it_behaves_like "redirect response"
        end

        context "when user enqueues post" do 
          let (:params) { { commit: "Publish", post: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph } } }

          it_behaves_like "redirect response"
        end
      end

      describe "when post is queued" do 
        before { new_post.enqueue }

        context "when user updates post attributes" do 
          let (:params) { { commit: "Publish", post: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph } } }

          it_behaves_like "redirect response"
        end

        context "when user dequeues post" do 
          let (:params) { { commit: "Save draft", post: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph } } }

          it_behaves_like "redirect response"
        end
      end

      describe "when post is public" do
        before { new_post.bribe }

        let (:params) { { post: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph } } }

        it_behaves_like "redirect response"
      end
    end

    describe "when user is admin" do 
      before { sign_in admin }

      describe "when post is draft" do 
        context "when user updates post attributes" do 
          let(:params) { { commit: "Save draft", post: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph } } }

          it_behaves_like "redirect response"
        end

        context "when user enqueues post" do 
          let (:params) { { commit: "Publish", post: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph } } }

          it_behaves_like "redirect response"
        end
      end

      describe "when post is queued" do 
        before { new_post.enqueue }

        context "when user updates post attributes" do 
          let (:params) { { commit: "Publish", post: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph } } }

          it_behaves_like "redirect response"
        end

        context "when user dequeues post" do 
          let (:params) { { commit: "Save draft", post: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph } } }

          it_behaves_like "redirect response"
        end
      end

      describe "when post is public" do
        before { new_post.bribe }

        let (:params) { { post: { title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph } } }

        it_behaves_like "redirect response"
      end
    end
  end

  describe "DELETE /destroy" do 
    subject { delete post_path(new_post), params: { id: new_post.id } }

    describe "when user is guest" do 
      it_behaves_like "redirect response"
      it_behaves_like "change number of posts", 0
    end

    describe "when user is post owner" do 
      before { sign_in user }

      it_behaves_like "redirect response"
      it_behaves_like "change number of posts", -1
    end

    describe "when user is admin" do 
      before { sign_in admin }
      
      it_behaves_like "redirect response"
      it_behaves_like "change number of posts", 0
    end
  end
end

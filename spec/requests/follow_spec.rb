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

RSpec.shared_examples "successfull" do 
  it "redirects to the followee page" do
    expect(subject).to redirect_to(user_path(users[1].id))
  end

  it "returns 200 OK response" do 
    subject
    expect(response).to have_http_status "200"
  end
end

RSpec.shared_context "when follow" do 
  subject { post user_follows_path(users[1].id), params: params, xhr: true }

  let (:params) { { id: users[1].id } }
end

RSpec.shared_context "when unfollow" do 
  subject { delete user_follow_path(users[1].id, users[1].id), params: params, xhr: true }

  let! (:follow) { create(:follow, follower: users[0], followee: users[1]) }
  let (:params) { { id: users[1].id, user_id: users[1].id } }
end



RSpec.describe "Follows", type: :request do
  let (:users) { create_list :user, 2 }

  describe "POST /create" do
    describe "when user is not logged in" do 
      include_context "when follow"     

      it_behaves_like "as a guest"
    end

    describe "when user is logged in" do 
      before { sign_in users[0] }

      include_context "when follow"

      it "creates a new follow record" do 
        expect { subject }.to change(Follow, :count).by(1)
      end

      it "creates a new notification record" do 
        expect { subject }.to change(Notification, :count).by(1)
      end

      it_behaves_like "successfull"
    end
  end

  describe "DELETE /destroy" do
    describe "when user is not logged in" do 
      include_context "when unfollow"      
    
      it_behaves_like "as a guest"
    end

    describe "when user is logged in" do 
      before { sign_in users[0] }

      include_context "when unfollow"      

      it "destroy a follow record" do 
        expect { subject }.to change(Follow, :count).by(-1)
      end

      it_behaves_like "successfull"
    end
  end
end

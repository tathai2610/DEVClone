require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Associations" do 
    it { should have_many(:posts).dependent(:destroy) }
    it { should have_many(:likes).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:followers).class_name("Follow").with_foreign_key("followee_id") }
    it { should have_many(:followees).class_name("Follow").with_foreign_key("follower_id") }
    it { should have_many(:rcvd_notifs).class_name("Notification").with_foreign_key("recipient_id") }
    it { should have_one_attached(:avatar) }
  end

  describe "Callbacks" do 
    # it { should callback(:add_default_avatar).after(:commit).on(:create, :update) }
    it { should callback(:add_default_avatar).after(:commit) }
  end

  describe "#name" do 
    let (:user) { create(:user) }
    context "when only first name is present" do
      it "return only first name" do
        user.first_name = Faker::Name.first_name
        expect(user.name).to eq(user.first_name)
      end
    end
    context "when only last name is present" do
      it "return only last name" do
        user.last_name = Faker::Name.last_name
        expect(user.name).to eq(user.last_name)
      end
    end
    context "when both first name and last name are present" do
      it "return full name" do
        user.first_name = Faker::Name.first_name
        user.last_name = Faker::Name.last_name
        expect(user.name).to eq("#{user.first_name} #{user.last_name}")
      end
    end
    context "when both first name and last name are blank" do
      it "return username" do
        expect(user.name).to eq(user.username)
      end
    end
  end

  describe "#bio" do 
    let (:user) { create(:user) }
    context "when description is present" do
      it "return description" do
        user.description = "im a dev"
        expect(user.bio).to eq("im a dev")
      end
    end
    context "when description is blank" do
      it "return 404" do
        expect(user.bio).to eq("404 bio not found")
      end
    end
  end

  describe "#number_of_posts" do 
    let (:user) { create(:user) }
    context "when user has one or more public posts" do
      it "return number of user's public posts" do
        create_list(:post, 3, user: user, state: :public)
        expect(user.number_of_posts).to eq(3)
      end
    end
    context "when user has no public post" do
      it "return number of user's public posts" do
        expect(user.number_of_posts).to eq(0)
      end
    end
  end

  describe "#comments_8_latest" do
    let (:user) { create(:user) }
    context "when user has one to 8 comments" do 
      it "return all of the comments" do 
        create_list(:comment, 3, user: user, commentable: create(:post))
        expect(user.comments_8_latest).to eq(user.comments.order("created_at DESC"))
      end
    end
    context "when user has more than 8 comments" do 
      it "return 8 latest comments" do 
        create_list(:comment, 10, user: user, commentable: create(:post))
        expect(user.comments_8_latest).to eq(user.comments.order("created_at DESC").first(8))
      end
    end
    context "when user has no comments" do 
      it "return nil" do 
        expect(user.comments_8_latest).to eq([])
      end
    end
  end

  describe "#following?" do
    let (:user_a) { create(:user) } 
    let (:user_b) { create(:user) }
    context "when current user is following other user" do
      it "return true" do 
        create(:follow, follower: user_a, followee: user_b)
        expect(user_a.following? user_b).to eq(true)
      end
    end
    context "when current user is not following other user" do
      it "return false" do 
        expect(user_a.following? user_b).to eq(false)
      end
    end
  end

  describe "#liked?" do 
    let (:user) { create(:user) }
    context "when likeable is a post" do
      let (:post) { create(:post) }
      context "and current user has liked it" do 
        it "return true" do 
          create(:like, user: user, likeable: post)
          expect(user.liked? post).to eq(true)
        end
      end
      context "and current user do not like it" do 
        it "return false" do 
          expect(user.liked? post).to eq(false)
        end
      end
    end
    context "when likeable is a comment" do
      let (:post) { create(:post) }
      let (:comment) { create(:comment, user: user, commentable: post)}
      context "and current user has liked it" do 
        it "return true" do 
          create(:like, user: user, likeable: comment)
          expect(user.liked? comment).to eq(true)
        end
      end
      context "and current user do not like it" do 
        it "return false" do 
          expect(user.liked? comment).to eq(false)
        end
      end
    end
  end

  describe "#add_default_avatar" do 
    let (:user) { build(:user) }
    context "when new user is not saved" do 
      it "do not save user avatar" do 
        expect(user.avatar).not_to be_attached
      end
    end
    context "when new user is saved" do 
      it "save user default avatar" do 
        user.save!
        expect(user.avatar).to be_attached
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should have_many(:likes).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should belong_to(:commentable) }
    it { should have_many(:notifs).class_name("Notification") }
  end

  describe "Validations" do 
    it { should validate_presence_of(:content) }
  end

  describe "Callbacks" do
    it { is_expected.to callback(:increase_count).after(:create) }
    it { is_expected.to callback(:decrease_count).after(:destroy) }
  end

  describe "#increase_count" do
    context "when commentable is a post" do
      let (:comment) { create :comment, :for_post }
      it "increase number of post's comments" do
        expect(comment.commentable.comments.size).to eq(comment.commentable.comments_count)
      end
    end
    context "when commentable is not a post" do
      let (:commentable) { create :comment, :for_post }
      let (:comment) { create :comment, commentable: commentable }
      it "remain number of post's comments" do
        expect(comment.post.comments.size).to eq(comment.post.comments_count)
      end
    end
  end

  describe "#decrease_count" do
    context "when commentable is a post" do
      let (:comment) { create :comment, :for_post }
      it "decrease number of post's comments" do
        comment.destroy
        expect(comment.commentable.comments.size).to eq(comment.commentable.comments_count)
      end
    end
    context "when commentable is not a post" do
      let (:commentable) { create :comment, :for_post }
      let (:comment) { create :comment, commentable: commentable }
      it "remain number of post's comments" do
        comment.destroy
        expect(comment.post.comments.size).to eq(comment.post.comments_count)
      end
    end
  end
end

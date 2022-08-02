require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe "Associations" do
    it { should belong_to(:follower).class_name("User") }
    it { should belong_to(:followee).class_name("User") }
  end
end

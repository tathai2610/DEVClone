require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe "Associations" do
    it { should have_many(:post_tags).dependent(:destroy) }
    it { should have_many(:posts).through(:post_tags) }
  end

  describe "Validations" do 
    it { should validate_presence_of(:title)}
  end
end

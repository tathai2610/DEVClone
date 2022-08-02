require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe "Associations" do 
    it { is_expected.to belong_to(:sender).class_name("User") }
    it { is_expected.to belong_to(:recipient).class_name("User") }
    it { is_expected.to belong_to(:notifiable) }
  end

  describe "Callbacks" do 
    it { is_expected.to callback(:notify_user).after(:commit) }
  end
end

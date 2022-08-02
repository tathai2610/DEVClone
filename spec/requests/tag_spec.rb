require 'rails_helper'

RSpec.describe "Tags", type: :request do
  describe "GET /show" do
    subject { get tag_path(tag.id) }

    let (:tag) { create(:tag) }

    it "renders a successful response" do
      subject
      expect(response).to be_successful
    end
  end
end

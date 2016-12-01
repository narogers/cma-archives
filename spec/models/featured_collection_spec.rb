require 'rails_helper'

RSpec.describe FeaturedCollection do
  describe "#icon" do
    it "should return an empty value" do
      featured_coll = FeaturedCollection.new
      expect(featured_coll.icon).to eq ""
    end
  end
end

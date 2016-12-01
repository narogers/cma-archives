require 'rails_helper'

RSpec.describe User do
  let(:user) { User.new(login: "archivist", email: "archivist@example.org") }

  describe "#groups" do
    it "should use the role map for access control" do
      expect(user.groups).to contain_exactly "archivist"
    end
  end

  describe "#to_s" do
    it "should use email as a label" do
      expect(user.to_s).to eq "archivist@example.org"
    end
  end
end

require 'rails_helper'

RSpec.describe CMAFileContentDatastream do
  let(:file) { FactoryGirl.create(:generic_image, 
    import_url: "file://#{File.expand_path("spec/fixtures/lagoon.jpg")}") }
  let(:file_content) { file.content }

  before(:each) do
    IngestLocalFileJob.new(file.id).run
  end

  describe "#container" do
    it "retains a reference to its container" do
      expect(file_content.container).to eq file
    end
  end

  describe "#checksum" do
    it "does not return the default null checksum" do
      expect(file_content.checksum).to_not eq "da39a3ee5e6b4b0d3255bfef95601890afd80709"
    end
  end
end 

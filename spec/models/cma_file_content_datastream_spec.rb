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
end 

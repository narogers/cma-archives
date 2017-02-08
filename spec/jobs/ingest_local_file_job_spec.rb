require 'rails_helper'

RSpec.describe IngestLocalFileJob do
  describe "#run" do
    let(:file) { FactoryGirl.create(:generic_image, import_url: "file://#{File.expand_path("spec/fixtures/lagoon.tif")}") }
    let(:resource_path) { file.local_file }
    let(:checksum_path) { "#{file.local_file}.sha1" }

    after(:each) do 
      File.delete resource_path if File.exists? resource_path
      File.delete checksum_path if File.exists? checksum_path
    end

    it "copies the file into the local repository" do
      allow(Sufia.queue).to receive(:push)
      expect(File.exists? resource_path).to eq false
   

      IngestLocalFileJob.new(file.id).run
      file.reload

      expect(File.exists? resource_path).to eq true
      expect(file.content.mime_type).to eq "message/external_body; access-type=URL; url=\"http://localhost:3000/downloads/#{file.id}\""
      expect(file.content.original_name).to eq "lagoon.tif"
      expect(file.content.size).to eq 109216

      expect(file.mime_type).to eq "image/tiff"
      expect(file.label).to eq "lagoon.tif"
      expect(file.title).to contain_exactly "lagoon.tif"
    end
  end
end

require 'rails_helper'

RSpec.describe CMA::ExternalChecksum do
  let!(:file) { FactoryGirl.create(:generic_image_with_content) }

  after(:each) do
    File.delete(file.local_file) if File.exists? file.local_file
  end

  describe "Valid checksum" do
    it "has generates valid RDF" do
      allow(Sufia.queue).to receive(:push)
      IngestLocalFileJob.new(file.id).run

      checksum = CMA::ExternalChecksum.new(file.content)
      
      expect(checksum.uri).to eq "urn:sha1:c98a7d2549289abcb7813e3e973ceb797511dfe1"
      expect(checksum.algorithm).to eq "sha1"
      expect(checksum.value).to eq "c98a7d2549289abcb7813e3e973ceb797511dfe1"
    end

    it "handles missing files" do
      checksum = CMA::ExternalChecksum.new(file.content)
 
      expect(checksum.uri).to be_nil 
      expect(checksum.algorithm).to be_nil
      expect(checksum.value).to be_nil
    end
  end
end

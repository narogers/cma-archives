require 'rails_helper'

RSpec.describe MigrateCollectionToExternalStorageJob do
  describe "#run" do
    let(:file) { FactoryGirl.create(:generic_image_with_content,
      import_url: "file://#{File.expand_path("spec/fixtures/lagoon.jpg")}") }
    let(:collection) { FactoryGirl.create(:collection, members: [file]) }
    let!(:user) { FactoryGirl.create(:user, login: "FactoryGirl") }

    it "leaves existing external content in place" do
      IngestLocalFileJob.new(file.id).run

      expect(File.exists?(file.local_file)).to be true
      expect(file.content.size).to eq 9610
      expect(Digest::SHA1.file(file.local_file).hexdigest).to eq "c98a7d2549289abcb7813e3e973ceb797511dfe1"
   
      MigrateCollectionToExternalStorageJob.new(collection.id).run

      expect(File.exists? file.local_file).to be true
      expect(file.content.size).to eq 9610
      expect(Digest::SHA1.file(file.local_file).hexdigest).to eq "c98a7d2549289abcb7813e3e973ceb797511dfe1"
    end

    it "migrates bitstreams from Fedora" do
      ImportUrlJob.new(file.id).run
      expect(File.exists?(file.local_file)).to be false
      expect(file.content.size).to be 9610

      MigrateCollectionToExternalStorageJob.new(collection.id).run

      expect(File.exists? file.local_file).to be true
      expect(File.size file.local_file).to be 9610
    end
  
    it "works with files no longer on disk" do
      ImportUrlJob.new(file.id).run
      file.import_url = "file://path-to-null-file"
      file.save

      expect(File.exists? file.import_url.gsub("file://", "")).to be false

      MigrateCollectionToExternalStorageJob.new(collection.id).run
  
      expect(File.exists? file.local_file).to be true
      expect(File.size file.local_file).to be 9610
      expect(Digest::SHA1.file(file.local_file).hexdigest).to eq "c98a7d2549289abcb7813e3e973ceb797511dfe1" 
      expect(file.import_url).to eq "file://path-to-null-file"
    end
  end
end

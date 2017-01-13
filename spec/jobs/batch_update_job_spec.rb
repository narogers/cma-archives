require 'rails_helper'

RSpec.describe BatchUpdateJob do
  before(:all) do
    Collection.create(title: "Batch Update Test", 
      id: "test-coll",
      edit_users: ["rspec"],
      depositor: "rspec")
  end

  after(:all) do
    Collection.destroy_all
  end

  describe "#run" do
    before(:each) do
      allow(ImportUrlJob).to receive(:new)
      allow(Sufia.queue).to receive(:push)
      BatchIngestJob.new("spec/fixtures/batch.csv").run
    end

    it "raises an error if file not found" do
      job = BatchUpdateJob.new "NoSuchFileOnDisk.csv"
      expect { job.run }.to raise_error(CMA::Exceptions::FileNotFoundError)
    end

    it "handles nil, single, and multivalued properties" do
      coll = find_collection_by_title "Test Batch Ingest"
      expect(coll.members.count).to be 3

      first_image = coll.members.first
      expect(first_image.accession_number).to be_empty
      expect(first_image.device).to be_empty
      expect(first_image.photographer).to eq ["Nathan Rogers"]
   
      BatchUpdateJob.new("spec/fixtures/updated-batch.csv").run      
      coll.reload
  
      first_image = coll.members.first
      expect(first_image.accession_number).to eq ["1915.241"]
      expect(first_image.device).to eq ["CAMERA"]
      expect(first_image.photographer).to contain_exactly("Greg Donley", "Nathan Rogers")

      expect(coll.members[1].accession_number).to contain_exactly("1901.42", "1954.23", "2004.154")
      expect(coll.members[1].device).to be_empty

      expect(coll.members[2].accession_number).to be_empty
      expect(coll.members[2].device).to eq ["TOPAZ"]
    end
  end
end

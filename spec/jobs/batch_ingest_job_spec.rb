require 'rails_helper'

RSpec.describe BatchIngestJob do
  after(:all) do
    AdministrativeCollection.destroy_all
    Collection.destroy_all
  end

  describe "#run" do
    before(:each) do
      policy = FactoryGirl.create(:administrative_collection, 
        title: ["Batch Tests"])
      policy.default_permissions.create(type: "group", access: "read", name: "photostudio")
      policy.default_permissions.create(type: "group", access: "edit", name: "rspec")
      policy.default_permissions.create(type: "group", access: "edit", name: "conservation")
    end
    
    after(:each) { teardown "Test Batch Ingest" }

    it "raises an error if file not found" do
      job = BatchIngestJob.new "NoSuchFileOnDisk.csv"
      expect { job.run }.to raise_error(CMA::Exceptions::FileNotFoundError)
    end

    it "raises an exception if batches do not exist" do
      job = BatchIngestJob.new nil
      expect(job.find_batch "bad-id").to be_nil
    end

    it "creates a new collection" do
      allow(IngestLocalFileJob).to receive(:new)
      allow(Sufia.queue).to receive(:push)

      BatchIngestJob.new("spec/fixtures/batch.csv").run      
      coll = find_collection_by_title "Test Batch Ingest"

      expect(coll.title).to eq "Test Batch Ingest"
      expect(coll.date_created).to contain_exactly "2016-03"
      expect(coll.members.count).to eq 3
      expect(coll.resource_type).to contain_exactly "Collection"
      expect(coll.administrative_collection.title).to eq "Batch Tests"
    end

    it "does not reprocess existing content" do
      allow(ImportUrlJob).to receive(:new)
      allow(Sufia.queue).to receive(:push)

      count = get_count("Test Batch Ingest") 
      expect(count).to eq 0

      BatchIngestJob.new("spec/fixtures/batch.csv").run
      coll = find_collection_by_title "Test Batch Ingest"
      count = get_count("Test Batch Ingest")

      expect(count).to be 1
      expect(coll.member_ids.count).to be 3
    end 
  end
end

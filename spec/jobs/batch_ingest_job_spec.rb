require 'rails_helper'

RSpec.describe BatchIngestJob do
  let(:batch) { "spec/fixtures/batch.csv" }

  before(:each) do
    Batch.destroy_all
  end

  after(:all) do
    AdministrativeCollection.destroy_all
    Collection.destroy_all
  end

  describe "#run" do
    before(:each) do
      FactoryGirl.create(:administrative_collection, title: ["Batch Tests"])
    end
    
    after(:each) { teardown "Test Batch Ingest" }

    it "raises an error if file not found" do
      job = BatchIngestJob.new "NoSuchFileOnDisk.csv"
      expect { job.run }.to raise_error(CMA::Exceptions::FileNotFoundError)
    end

    it "fails if the batch id is invalid" do
      job = BatchIngestJob.new batch, "bad-id"
      expect { job.run }.to raise_error ActiveFedora::ObjectNotFoundError
    end

    it "creates a new collection" do
      allow(IngestLocalFileJob).to receive(:new)
      allow(Sufia.queue).to receive(:push)

      expect(Batch.count).to eq 0

      BatchIngestJob.new(batch).run      
      coll = find_collection_by_title "Test Batch Ingest"

      expect(Batch.count).to eq 1
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

      BatchIngestJob.new(batch).run
      coll = find_collection_by_title "Test Batch Ingest"
      count = get_count("Test Batch Ingest")

      expect(count).to be 1
      expect(coll.member_ids.count).to be 3
    end 
  end
end

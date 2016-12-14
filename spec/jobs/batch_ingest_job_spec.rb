require 'rails_helper'

RSpec.describe BatchIngestJob do
  before(:all) do
    @parent = Collection.new(title: "Batch Tests", id: "umbrella-coll")
    @parent.edit_users = ["admin"]
    @parent.edit_groups = ["rspec", "pry"]
    @parent.depositor = "admin"
    @parent.save
 end

  after(:all) do
    Collection.destroy_all
  end

  describe "#run" do
    before(:each) do
      @parent.members = []
      @parent.save
    end
 
    after(:each) do
      teardown "Test Batch Ingest"
    end

    it "raises an error if file not found" do
      job = BatchIngestJob.new "NoSuchFileOnDisk.csv"
      expect { job.run }.to raise_error(CMA::Exceptions::FileNotFoundError)
    end

    it "creates a new collection" do
      allow(ImportUrlJob).to receive(:new)
      allow(Sufia.queue).to receive(:push)

      BatchIngestJob.new("spec/fixtures/batch.csv").run      
      coll = find_by_title "Test Batch Ingest"

      expect(coll.title).to eq "Test Batch Ingest"
      expect(coll.date_created).to contain_exactly "2016-03"
      expect(coll.collections).to contain_exactly @parent
      expect(coll.members.count).to eq 3
      expect(coll.resource_type).to contain_exactly "Collection"
      expect(coll.edit_groups).to contain_exactly "admin", "rspec", "pry"
    end

    it "does not reprocess existing content" do
      allow(ImportUrlJob).to receive(:new)
      allow(Sufia.queue).to receive(:push)

      count = get_count("Test Batch Ingest") 
      expect(count).to eq 0

      BatchIngestJob.new("spec/fixtures/batch.csv").run
      coll = find_by_title "Test Batch Ingest"
      count = get_count("Test Batch Ingest")

      expect(count).to be 1
      expect(coll.member_ids.count).to be 3

      BatchIngestJob.new("spec/fixtures/batch.csv").run
      coll = find_by_title "Test Batch Ingest"
      count = get_count("Test Batch Ingest")

      expect(count).to be 1
      expect(coll.member_ids.count).to be 3
    end 
  end
end

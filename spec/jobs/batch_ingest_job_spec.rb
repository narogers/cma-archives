require 'rails_helper'

RSpec.describe BatchIngestJob do
  describe "#run" do
    before(:all) do
      @parent = Collection.new(title: "Batch Tests")
      @parent.edit_users = ["admin"]
      @parent.depositor = "admin"
      @parent.save
    end

    before(:each) do
      @parent.members = []
      @parent.save
    end

    it "raises an error if file not found" do
      job = BatchIngestJob.new "NoSuchFileOnDisk.csv"
      expect { job.run }.to raise_error(CMA::Exceptions::FileNotFoundError)
    end

    it "creates a new collection" do
      #allow(ImportUrlJob).to receive(:new)
      allow(Sufia.queue).to receive(:push)
      job = BatchIngestJob.new "spec/fixtures/new_batch.csv"
      job.run
      
      coll = Collection.where(title_tesim: "New Batch Ingest").first
      expect(coll.title).to eq "New Batch Ingest"
      expect(coll.date_created).to contain_exactly "2016-03"
      expect(coll.collections).to contain_exactly @parent
    end
  end
end

require 'rails_helper'


RSpec.describe BatchIngestJob do
  before(:all) do
    @parent = Collection.new(title: "Batch Tests", id: "umbrella-coll")
    @parent.edit_users = ["admin"]
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
      job = BatchIngestJob.new "spec/fixtures/batch.csv"
      job.run
      
      ids = Collection.find_with_conditions("title_tesim: \"Test Batch Ingest\"")
      coll = Collection.load_instance_from_solr(ids.first["id"])

      expect(coll.title).to eq "Test Batch Ingest"
      expect(coll.date_created).to contain_exactly "2016-03"
      expect(coll.collections).to contain_exactly @parent
      expect(coll.members.count).to be 3

      # Because it takes so long to process we also test the properties of the
      # generic files here to see if they are as expected
    end

    it "does not reprocess existing content" do
      allow(ImportUrlJob).to receive(:new)
      allow(Sufia.queue).to receive(:push)

      count = Collection.count(conditions: "title_tesim: \"Test Batch Ingest\"") 
      expect(count).to be 0

      job = BatchIngestJob.new "spec/fixtures/batch.csv"
      job.run  

      ids = Collection.find_with_conditions("title_tesim: \"Test Batch Ingest\"")     
      coll = Collection.load_instance_from_solr(ids.first["id"]) 
      expect(ids.count).to be 1
      expect(coll.members.count).to be 3

      job.run
      coll = Collection.load_instance_from_solr(coll.id)

      count = Collection.count(conditions: "title_tesim: \"Test Batch Ingest\"")      
      # TODO: Tests fail here because no label is set since ImportUrlJob never
      #       actually runs. The fix is to stub out the method more fully.
      expect(count).to be 1
      expect(coll.members.count).to be 3
    end 
  end
end

def teardown collection_name
  coll = Collection.find_with_conditions("title_tesim: \"#{collection_name}\"")
  unless coll.blank?
    coll = Collection.find(coll.first["id"]).destroy
  end
end

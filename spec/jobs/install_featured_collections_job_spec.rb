RSpec.describe InstallFeaturedCollectionsJob do
  before(:all) do
    # NO OP
  end

  after(:all) do
    # NO OP
  end

  describe "#run" do
    before(:each) do
      FeaturedCollection.delete_all
      Collection.delete_all
    end

    it "loads collections from a Hash" do
      source = FactoryGirl.build_list(:collection_hash, 1)
      InstallFeaturedCollectionsJob.new(source).run

      coll = Collection.first
      expect(FeaturedCollection.count).to eq 1
      expect(Collection.count).to eq 1
      expect(coll.title).to eq source.first[:title]
      expect(coll.description).to eq source.first[:description]
    end

    it "fails on invalid collections" do
      source = "spec/fixtures/invalid_collections.yml"
 
      job = InstallFeaturedCollectionsJob.new(source)
      expect { job.run }.to raise_error CMA::Exceptions::MissingValueError 
    end

    it "creates new collections" do
      source = "spec/fixtures/featured_collections.yml"
      InstallFeaturedCollectionsJob.new(source).run
      
      expect(FeaturedCollection.count).to eq 3
      expect(Collection.count).to eq 3
      editorial = Collection.find(title: "Editorial Photography").first
      expect(editorial.title).to eq "Editorial Photography"
      expect(editorial.read_groups).to contain_exactly "photostudio"
    end
   
    it "updates relationships for existing collections" do
      source = "spec/fixtures/featured_collections.yml"
      job = InstallFeaturedCollectionsJob.new(source)
      job.run

      expect(FeaturedCollection.count).to eq 3
      expect(Collection.count).to eq 3
    
      FeaturedCollection.delete_all
      expect(FeaturedCollection.count).to eq 0
      expect(Collection.count).to eq 3

      job.run
      expect(FeaturedCollection.count).to eq 3
      expect(Collection.count).to eq 3      
    end
  end

  describe "#load_collections" do
    it "loads collections from YAML" do
       source = "spec/fixtures/featured_collections.yml"
       
       job = InstallFeaturedCollectionsJob.new(source)
       collections = job.load_collections(source)
       expect(collections.count).to be 3
       expect(collections.first[:title]).to eql "Editorial Photography"
       expect(collections.first[:description]).to eql "Born digital photographs of people, events, exhibitions, and the building." 
    end

    it "fails on missing files" do
      source = "spec/fixtures/No File Here.yml"
  
      job = InstallFeaturedCollectionsJob.new(source)
      expect { job.load_collections(source) }.to raise_error CMA::Exceptions::FileNotFoundError
    end
  end
end

RSpec.describe InstallFeaturedCollectionsJob do
  before(:all) do
    # NO OP
  end

  after(:all) do
    # NO OP
  end

  describe "#run" do
    before(:each) do
      # NO OP
    end

    after(:each) do
      FeaturedCollection.delete_all
    end

    it "loads collections from YAML" do
    end

    it "loads collections from a Hash" do
    end

    it "creates new collections" do
    end
   
    it "updates relationships for existing collections" do
    end
  end
end

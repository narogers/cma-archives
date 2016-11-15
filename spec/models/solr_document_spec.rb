require 'rails_helper'

RSpec.describe SolrDocument do
  describe "GenericFile representration" do
    let(:generic_file) { create(:generic_file, source: ["MySourceFile.tif"], subject: ["RSpec", "Test Coverage"]) }
    let(:solr_doc) { SolrDocument.new(generic_file.to_solr) }

    it "should be able to retrieve indexed properties" do
      expect(solr_doc.source).to eq "MySourceFile.tif"
      expect(solr_doc.subject).to contain_exactly "RSpec", "Test Coverage"
      expect(solr_doc.members).to be_nil
    end
  end

  describe "Collection representation" do
    let(:collection) { create(:collection, subject: ["RSpec Mocks"]) }
    let(:solr_doc) { SolrDocument.new(collection.to_solr) }
    
    it "should provide sensible defaults" do
      expect(solr_doc.source).to be_nil
      expect(solr_doc.subject).to contain_exactly "RSpec Mocks"
      expect(solr_doc.members).to eq []
      expect(solr_doc.bytes).to be 0
    end
  end
end

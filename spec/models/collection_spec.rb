require 'rails_helper'

RSpec.describe Collection, type: :model do
  describe "#normalize_title" do
    let(:lower_coll) { Collection.new(title: "test title 123.45") }
    let(:upper_coll) { Collection.new(title: "UPPER CASE TITLE") }
    let(:mixed_coll) { Collection.new(title: "Cma galleries on MlK Day 2015") }

    it "normalizes a lower case title" do
      expect(lower_coll.normalize_title).to eq "Test Title 123.45"
    end

    it "normalizes an upper case title" do
      expect(upper_coll.normalize_title).to eq "Upper Case Title"
    end

    it "normalizes acronyms properly" do
      expect(mixed_coll.normalize_title).to eq "CMA Galleries On MLK Day 2015"
    end
  end

  describe "#update_permissions" do
    let(:parent_collection) { Collection.new(title: "Parent Collection", edit_groups: [:foo], read_groups: [:bar]) }
    let(:subcollection) { Collection.new(title:"Subcollection", collections: [parent_collection]) }

    it "assigns descending permissions" do
      subcollection.update_permissions
      expect(subcollection.read_groups).to eq(parent_collection.read_groups)
      expect(subcollection.edit_groups).to eq(parent_collection.edit_groups)
    end
  end

  describe "#bytes" do
    let(:collection_ids) { [ {"id": "rspec-mock"} ] }
    let(:empty_result) { { "stats" => { "stats_fields" => {} }}} 
    let(:collection) { create :collection }

    it "reports 0 for an empty collection" do
      allow(ActiveFedora::SolrService).to receive(:query).
        with("*:*", anything).
        and_return(collection_ids, empty_result)
      expect(collection.bytes).to eq 0           
    end

    let(:solr_response) { { "stats" => { "stats_fields" => { "file_size_ltsi" => { "sum" => 45921 }}}}}
    it "reports an accurate total for members" do
      allow(ActiveFedora::SolrService).to receive(:query).
        with("*:*", anything).
        and_return(collection_ids, solr_response)
      expect(collection.bytes).to eq 45921
    end
  end

  describe "MIME type detection" do
    let(:collection) { create :collection }
    let(:image) { create :generic_image }
    let(:audio) { create :generic_audio }
    let(:video) { create :generic_video }
    
    before(:each) do
      collection.members = []
      collection.save
    end

    it "reports false for an empty collection" do
      expect(collection.has_audio?).to be false
      expect(collection.has_video?).to be false
      expect(collection.has_images?).to be false
      expect(collection.has_pdfs?).to be false
    end

    it "reports true for a collection of images" do 
      collection.members += [image]
      collection.save
      
      expect(collection.has_audio?).to be false
      expect(collection.has_images?).to be true 
    end

    it "reports true for hybrid collections" do
      collection.members += [video, audio]
      collection.save

      expect(collection.has_audio?).to be true
      expect(collection.has_video?).to be true
      expect(collection.has_images?).to be false
    end
  end
end


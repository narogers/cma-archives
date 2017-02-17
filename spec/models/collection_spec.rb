require 'rails_helper'

RSpec.describe Collection, type: :model do
  describe "#normalize_title" do
    let(:lower_coll) { Collection.new(title: "test title 123.45") }
    let(:upper_coll) { Collection.new(title: "UPPER CASE TITLE") }
    let(:mixed_coll) { Collection.new(title: "Cma galleries on MlK Day 2015") }
    let(:weekly_ingest) { Collection.new(title: "WIB219") }
   
    it "normalizes a lower case title" do
      lower_coll.normalize_title
      expect(lower_coll.title).to eq "Test Title 123.45"
    end

    it "normalizes an upper case title" do
      upper_coll.normalize_title
      expect(upper_coll.title).to eq "Upper Case Title"
    end

    it "normalizes acronyms properly" do
      mixed_coll.normalize_title
      expect(mixed_coll.title).to eq "CMA Galleries On MLK Day 2015"

      weekly_ingest.normalize_title
      expect(weekly_ingest.title).to eq "WIB219"
    end
  end

  describe "#bytes" do
    let(:empty_collection) { FactoryGirl.create :collection }
    let(:collection_with_member) do
      c = FactoryGirl.create :collection
      m = FactoryGirl.create :generic_image_with_content
      IngestLocalFileJob.new(m.id).run
      c.members += [m]
      c.save
      m.save

      c 
    end

    it "reports 0 for an empty collection" do
      expect(empty_collection.bytes).to eq 0           
    end

    it "reports an accurate total for members" do
      allow(Sufia.queue).to receive(:push)
      expect(collection_with_member.bytes).to eq 9610
    end
  end

  describe "MIME type detection" do
    let(:collection) { FactoryGirl.create :collection }
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


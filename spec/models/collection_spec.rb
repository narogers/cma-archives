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
end


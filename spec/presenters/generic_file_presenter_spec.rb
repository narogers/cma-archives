require 'rails_helper'

RSpec.describe CMA::GenericFilePresenter do
  let(:file) { build(:generic_file, { id: "rspec-presenter", title: ["Presenter Test"] }) }
  let(:presenter) { described_class.new(SolrDocument.new(file.to_solr)) }
 
  describe "#date_created" do
    it "defaults to a sane value" do 
      expect(presenter.date_created).to eq ["-"]
    end
  end

  describe "#id" do
    it "always returns a singular value" do
      expect(presenter.id).to eq "rspec-presenter"
    end
  end

  describe "#itemtype" do
    it "is always CreativeWork" do
      expect(presenter.itemtype).to eq "http://schema.org/CreativeWork"
    end
  end

  describe "#member_presenters" do
    it "has no members" do
      expect(presenter.member_presenters).to be_empty
    end
  end
end

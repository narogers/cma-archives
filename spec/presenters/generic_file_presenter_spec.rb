require 'rails_helper'

RSpec.describe CMA::GenericFilePresenter do
  let(:file) do 
    create(:generic_image_with_content, 
      id: "rspec-presenter", 
      title: ["Presenter Test"])
  end
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

  describe "#title" do
    it "shows the primary title" do
      expect(presenter.title).to eq "Presenter Test"
    end
  end

  describe "#description" do
    let(:presenter_with_description) do
      file.description = ["A mock object from FactoryGirl"]
      described_class.new(SolrDocument.new(file.to_solr))
    end
    
    it "defaults to an empty description" do 
      expect(presenter.description).to eq ""
    end
   
    it "shows the primary description" do
      expect(presenter_with_description.description).to eq "A mock object from FactoryGirl"
    end
  end

  describe "#bytes" do
    let(:presenter_with_file) do
      IngestLocalFileJob.new(file.id).run
      described_class.new(SolrDocument.new(file.to_solr))
    end
    it "humanizes the byte count" do
      expect(presenter_with_file.bytes).to eq "9.38 KB"
    end
  end
end

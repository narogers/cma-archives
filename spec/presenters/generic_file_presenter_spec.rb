require 'rails_helper'

RSpec.describe CMA::GenericFilePresenter do
  describe "#date_created" do
    let(:file) { build(:generic_file) }
    let(:presenter) { described_class.new(SolrDocument.new(file.to_solr)) }
  
    it "should return an array of dates" do
      expect(presenter.date_created.class).to eq Array 
    end
  end  
end

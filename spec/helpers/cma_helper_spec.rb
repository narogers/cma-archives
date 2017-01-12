require 'rails_helper'

RSpec.describe CMAHelper, type: :helper do
  describe "#collection_facet_for_link" do
    let(:facet) { ActiveFedora::SolrQueryBuilder.solr_name("administrative_collection", :facetable) }
    let(:collection) { "Exhibition Photography" }
    let(:key) { "f[#{facet}][]" }

    it "creates a hash for link_to" do
      result = helper.collection_params_for_catalog collection
      expect(result.keys).to contain_exactly key
      expect(result[key]).to eq collection
    end
  end
end

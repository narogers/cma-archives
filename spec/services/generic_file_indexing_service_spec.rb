require 'rails_helper'

RSpec.describe CMA::GenericFileIndexingService do
  describe "#generate_solr_document" do
    before(:each) do
      allow(gf.content).to receive(:has_content?).and_return(false)
    end

    let(:gf) do
      GenericFile.new(title: ["RSpec (GenericFileIndexingService)"],
        mime_type: "image/tiff",
        contributor: ["Contributor"],
        photographer: ["Photographer"],
        accession_number: ["1942.214.10"])
    end  
 
    let(:small_file) { 415 }
    let(:large_file) { 5402680725 }

    it "collapses contributors into one facet" do
      solr_doc = gf.to_solr
      expect(solr_doc["contributor_facet_sim"]).to contain_exactly "Contributor", "Photographer"
    end

    it "indexes multiple variations for accession numbers" do
      solr_doc = gf.to_solr
      expect(solr_doc["accession_number_tesim"]).to contain_exactly "1942.214", "1942.214.10"
    end
  
    it "indexes small files" do
      
      allow(gf.content).to receive(:size).and_return(small_file)
      solr_doc = gf.to_solr
      expect(solr_doc["file_size_ltsi"]).to eq 415
    end

    it "indexes large files" do
      allow(gf.content).to receive(:size).and_return(large_file)
      solr_doc = gf.to_solr
      expect(solr_doc["file_size_ltsi"]).to eq 5402680725
    end
  end 
end

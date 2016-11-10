require 'rails_helper'
require 'webmock/rspec'

WebMock.allow_net_connect!

RSpec.describe Fixity do
  let(:generic_file) { FactoryGirl.create(:generic_file,
    import_url: "file://#{Rails.root}/spec/fixtures/lagoon.tif") }
  
  describe "#remote" do
    let(:rdf) { File.read("spec/fixtures/fixity.rdf") }
    let(:fixity) { Fixity.new generic_file.id }

    before(:each) do
      stub_request(:any, /.*fedora\/rest\/.*\/content\/fcr:fixity/).
        and_return(status: 200, body: rdf)
    end

    it "should have a valid checksum" do
     expect(fixity.remote[:checksum]).to eq "f4bdeae4040d68a3977dee8d9a31a0137e741c44"
    end
    
    it "should encode checksum in SHA1" do
       expect(fixity.remote[:algorithm]).to eq "sha1"
    end

    it "should validate against Fedora's fixity service" do
      expect(fixity.remote[:uri]).to end_with("/content/fcr:fixity")
    end
  end

  describe "#local" do
  end
end

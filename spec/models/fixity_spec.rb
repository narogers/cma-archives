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
     expect(fixity.remote).to eq "f4bdeae4040d68a3977dee8d9a31a0137e741c44"
    end
  end

  describe "#local" do
    it "should be able to recover from bad file paths" do
      file = FactoryGirl.create(:generic_file, 
        import_url: "file://dev/null/badFilePath.png")
      fixity = Fixity.new file.id
      expect(fixity.local).to eq false
    end

    it "should use SHA1 checksums" do
      fixity = Fixity.new generic_file.id
      expect(fixity.local).to eq "d5dec89bed8b8ca7555ba7c947809bf28720b08c"
    end
  end
end

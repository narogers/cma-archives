require 'rails_helper'
require 'webmock/rspec'

WebMock.allow_net_connect!

RSpec.describe CMA::CharacterizationService do
  let(:file) { FactoryGirl.create(:generic_image_with_content,
    import_url: "file://#{Rails.root}/spec/fixtures/lagoon.jpg") }
  
  describe "#characterize" do
    before(:each) do
      @default_timeout = CMA.config["fits"]["timeout"]
    end
   
    after(:each) do
      CMA.config["fits"]["timeout"] = @default_timeout
    end

    it "gracefully recovers from timeout errors" do
      CMA.config["fits"]["timeout"] = 0
      allow(Sufia.queue).to receive(:push)
      IngestLocalFileJob.new(file.id).run

      expect { CMA::CharacterizationService.characterize(file.content) }.to raise_error(Net::ReadTimeout) 
    end

    it "recovers from non 200 response codes" do
      stub_request(:any, /\/fits/).
        to_return(status: [500, "Service Unavailable"])
      allow(Sufia.queue).to receive(:push)
      IngestLocalFileJob.new(file.id).run

      expect { CMA::CharacterizationService.characterize(file.content) }.to raise_error(CMA::UnexpectedServerResponse)
    end
  end
end

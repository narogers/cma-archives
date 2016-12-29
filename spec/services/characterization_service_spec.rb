require 'rails_helper'
require 'webmock/rspec'

WebMock.allow_net_connect!

RSpec.describe CMA::CharacterizationService do
  let(:file) { FactoryGirl.create(:generic_image_with_content,
    import_url: "file://#{Rails.root}/spec/fixtures/lagoon.jpg") }
  
  describe "#characterize" do
    it "gracefully recovers from timeout errors" do
      pending "To be implemented later"
      stub_request(:any, /\/fits/).to_timeout
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

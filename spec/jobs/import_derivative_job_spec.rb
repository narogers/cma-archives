require 'rails_helper'

RSpec.describe ImportDerivativeJob do
  describe "#run" do
    it "warns about missing identifiers" do
      job = ImportDerivativeJob.new("invalid-id", "thumbnail", "spec/fixtures/lagoon.jpg")
      expect { job.run }.to raise_error(ActiveFedora::ObjectNotFoundError)
    end

    it "prevents updating the master content" do
      job = ImportDerivativeJob.new("abc123", "content", "spec/fixtures/lagoon.jpg")
      expect { job.run }
    end

    it "handles a bad file path" do
      gf = FactoryGirl.create(:generic_image_with_content, 
        title: ["Test Image"],
        depositor: "RSpec")
      job = ImportDerivativeJob.new(gf.id, "thumbnail", 
        "/bad/path/to/image.jpg")
      expect { job.run }.to raise_error(CMA::Exceptions::FileNotFoundError)
    end
 
    it "replaces a broken derivative" do
      gf = FactoryGirl.create(:generic_image_with_content,
        title: ["Test Image"],
        depositor: "RSpec")
      ImportDerivativeJob.new(gf.id, "thumbnail", "spec/fixtures/lagoon-flipped.png").run
      
      gf.reload
      expect(gf.thumbnail.original_name).to eq "lagoon-flipped.png"
      expect(gf.thumbnail.size).to eq 62363
      expect(gf.thumbnail.mime_type).to eq "image/png"    
    end
 end
end

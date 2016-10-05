require 'rails_helper'

RSpec.describe ExtractExifMetadataJob do
  describe "#run" do
    let(:gf) do
      GenericFile.create(title: ["RSpec test (run)"], 
        depositor: "RSpec", 
        edit_users: ["RSpec"],
        mime_type: "image/tiff")
    end
    let(:file) { File.read("spec/fixtures/lagoon.jpg") }
    let(:fields) { { subject: :subject, description: :description, date_created: :date_created } }
    let(:exif) do 
      { subject: ["Cubism", "Installation", "Exhibition | Picasso's Early Years"],
        description: "A retrospective look at the creative development of Picasso",
        date_created: DateTime.parse("2015-12-03").to_s 
      }
    end
 
    it "extracts EXIF metadata from the image" do
      allow(Sufia.config).to receive(:exif_to_desc_mapping).and_return(fields)
      allow(MiniExiftool).to receive(:new).and_return(exif)

      allow_any_instance_of(CMAFileContentDatastream).to receive(:has_content?).and_return(true)
      allow_any_instance_of(CMAFileContentDatastream).to receive(:content).and_return(file)
 
      expect(gf.subject).to eq [] 
      expect(gf.description).to eq []
      expect(gf.contributor).to eq []
      ExtractExifMetadataJob.new(gf.id).run

      gf.reload
      expect(gf.subject).to eq ["Cubism", "Installation", "Exhibition -- Picasso's Early Years"]
      expect(gf.description).to eq ["A retrospective look at the creative development of Picasso"]     
      expect(gf.date_created).to eq ["2015-12-03T00:00:00+00:00"]
      # TODO: Refactor into its own test?
      expect(gf.rights).to eq ["Copyright, The Cleveland Museum of Art"]
      expect(gf.contributor).to eq ["Cleveland Museum of Art"]
      expect(gf.language).to eq ["en"]
      expect(gf.resource_type).to contain_exactly "Image"
    end
 end

  describe "#normalize" do
    let(:job) { ExtractExifMetadataJob.new(nil) }

    it "converts pipes to dashes" do
      output = job.normalize("One|Two")
      expect(output).to eq "One--Two"
    end

    it "handles Arrays as well as Strings" do
      output = job.normalize(["Red Fish", "Blue Fish", "One Fish", "Two Fish"])
      expect(output).to eq ["Red Fish","Blue Fish","One Fish","Two Fish"]
    end

    it "escapes control characters" do
      output = job.normalize("\u0012This string is inva\u0001lid\u0004")
      expect(output).to eq "This string is invalid"
    end
  end
end

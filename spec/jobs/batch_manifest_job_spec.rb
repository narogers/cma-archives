require 'rails_helper'

RSpec.describe BatchManifestJob do
  describe "#run" do
    let(:csv_fixture) { "spec/fixtures/batch.csv" }

    before do
      allow(ImportUrlJob).to receive(:new)
      allow(Sufia.queue).to receive(:push)

      @batch = Batch.create(id: "rspec-mock", title: ["RSpec Batch Manifest Test"])
    end
  
    after do
      File.delete(@report) unless @report.nil?
      ActiveFedora::Cleaner.clean!
    end

    it "generates a valid CSV file" do
      BatchIngestJob.new(csv_fixture, @batch.id).run
      @report = BatchManifestJob.new(@batch.id).run
      csv = CSV.read @report, "r"

      expect(csv[0]).to eq ["RSpec Batch Manifest Test"]
      expect(csv[1].first).to start_with "http://"
      expect(csv[1].first).to end_with "/catalog?q=rspec-mock&search_field=batch"
      expect(csv[2].first).to start_with DateTime.now.strftime("%B %-d, %Y")

      expect(csv[5][0]).to eq "01.tif"
      expect(csv[5][1]).to start_with "file://"
      expect(csv[5][1]).to end_with "spec/fixtures/01.tif"
      expect(csv[5][2]).to start_with "http://"
      expect(csv[5][2]).to include "/fedora/rest"
      # Default values for checksums
      expect(csv[5][3]).to eq "false"
      expect(csv[5][4]).to eq "false"

      expect(csv.size).to eq 8
    end
  end 
end

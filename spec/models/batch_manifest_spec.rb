require 'rails_helper'

RSpec.describe BatchManifest do
  describe "#run" do
    let(:csv_fixture) { "spec/fixtures/batch.csv" }
    let(:batch_root) { "#{Rails.root}/spec/fixtures" }

    before do
      allow(ImportUrlJob).to receive(:new)
      allow(Sufia.queue).to receive(:push)
    end
  
    after do
      File.delete(@report) unless @report.nil?
      ActiveFedora::Cleaner.clean!
    end

    it "generates a valid CSV file" do
      BatchIngestJob.new(csv_fixture).run
      @report = BatchManifest.new(batch_root).generate
      csv = CSV.read @report, "r"

      expect(csv[0]).to eq ["#{Rails.root}/spec/fixtures"]
      expect(csv[3]).to include "file", "id", "collection", "batch", 
        "fixity", "uri"
      expect(csv.size).to eq 7

      expect(csv[4][1]).to eq "01.tif"
      expect(csv[4][5]).to start_with "http://localhost:3000"
      expect(csv[5][1]).to eq "02.tif"
      expect(csv[5][4]).to eq "false"
      expect(csv[6][1]).to eq "03.tif"
    end

    it "reports files which have not been ingested" do
      @report =  BatchManifest.new(batch_root).generate
      csv = CSV.read @report, "r"

      expect(csv.size).to eq 7
      expect(csv[4]).to match_array [nil, "01.tif", "Test Batch Ingest", nil, nil, nil]
    end
  end 
end

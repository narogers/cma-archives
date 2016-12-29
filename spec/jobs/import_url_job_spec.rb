require 'rails_helper'

RSpec.describe ImportUrlJob do
  describe "#run" do
    let(:file_path) { File.expand_path("spec/fixtures/lagoon.jpg") }
    let(:uri) { "file://#{file_path}" }
    let(:generic_file) { create(:generic_file, depositor: "rspec", edit_users: ["rspec"], import_url: uri) }
    let(:job) { ImportUrlJob.new generic_file.id }

    it "should ingest the bitstream(s) into Fedora" do
      expect(job.queue_name).to eq :import
      expect(generic_file.content.has_content?).to be false
      expect(generic_file.content.size).to eq 0

      job.run
      generic_file.reload

      expect(generic_file.content.has_content?).to be true
      expect(generic_file.content.size).to eq 9610
      expect(generic_file.mime_type).to eq "image/jpeg"
      expect(File.exists? generic_file.local_file).to be false
    end
  end
end

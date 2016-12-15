require 'rails_helper'

RSpec.describe IngestFileIntoLocalRepositoryService do
  
  describe "#ingest" do
    let(:file_path) { file.local_file }
    let(:sha1_path) { file.local_file + ".sha1" }
    let(:file_stat) { File.stat file_path }

    context "Valid file path" do
      let(:file) { FactoryGirl.create(:generic_image, 
        import_url: "file://" + File.expand_path("spec/fixtures/lagoon.jpg")) }

      it "copies files into the repository" do
        expect(File.exists? file_path).to be false
      
        IngestFileIntoLocalRepositoryService.ingest file
  
        expect(File.exists? file_path).to be true 
        expect(File.size file_path).to be 9610
        expect(Etc.getpwuid(file_stat.uid).name).to eq "nrogers"
        expect(Etc.getgrgid(file_stat.gid).name).to eq "nrogers"
      end

      it "raises an exception if permission denied" do
        allow(FileUtils).to receive(:cp).and_raise(Errno::EACCES.new)
        expect { IngestFileIntoLocalRepositoryService.ingest file }.to raise_error FileIngestError
      end 

      it "emits warnings if permissions cannot be reset" do
        allow(FileUtils).to receive(:chown).and_raise(Errno::EPERM.new)
     
        IngestFileIntoLocalRepositoryService.ingest file
        expect(File.exists? file_path).to be true
      end
    end

    context "Previously ingested file" do
      let(:file) do
        f = FactoryGirl.create(:generic_image)
        f.import_url = "file://#{f.local_file}"
        f.save 

        f.reload
      end
 
      it "does not ingest itself" do
        expect { IngestFileIntoLocalRepositoryService.ingest file}.to raise_error(FileIngestError)
      end
    end
  end
end

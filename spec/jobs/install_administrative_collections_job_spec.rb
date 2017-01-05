require 'rails_helper'

RSpec.describe InstallAdministrativeCollectionsJob do
  describe "#run" do
    let(:source) { "spec/fixtures/test_acls.yml" }

    before(:each) do
      AdministrativeCollection.delete_all
    end

    it "loads collections from a Hash" do
      hash = FactoryGirl.build_list(:policies_hash, 1)
      InstallAdministrativeCollectionsJob.new(hash).run

      collection = AdministrativeCollection.first
      expect(AdministrativeCollection.count).to eq 1
      expect(collection.title).to eq hash.first[:title]
      expect(collection.description).to eq hash.first[:description]
    end

    it "fails on malformed YAML" do
      bad_source = "spec/fixtures/invalid_acls.yml"
 
      job = InstallAdministrativeCollectionsJob.new(bad_source)
      expect { job.run }.to raise_error CMA::Exceptions::MissingValueError 
    end

    it "fails when given a missing YAML file" do
      bad_path = "spec/fixtures/null_policies.yml"
      job = InstallAdministrativeCollectionsJob.new(bad_path)
      
      expect { job.run }.to raise_error CMA::Exceptions::FileNotFoundError
    end

    it "creates new administrative collections" do
      InstallAdministrativeCollectionsJob.new(source).run
      editorial_policy = find_policy_by_title("Editorial Photography")
 
      expect(AdministrativeCollection.count).to eq 3
      expect(editorial_policy).to_not be_nil
      expect(editorial_policy.discover_groups).to be_empty
      expect(editorial_policy.read_groups).to contain_exactly "photostudio"
      expect(editorial_policy.edit_groups).to be_empty

      permission = editorial_policy.default_permissions.first
      expect(permission.agent_name).to eq "photostudio"
      expect(permission.access).to eq "read"
    end
   
    it "updates existing administrative collections" do
      InstallAdministrativeCollectionsJob.new(source).run
      expect(AdministrativeCollection.count).to eq 3
   
      InstallAdministrativeCollectionsJob.new(source).run
      expect(AdministrativeCollection.count).to eq 3      
    end
  end
end

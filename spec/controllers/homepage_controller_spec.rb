require 'rails_helper'

RSpec.describe HomepageController, type: :controller do
  routes { Sufia::Engine.routes }
 
  before(:all) do
    InstallAdministrativeCollectionsJob.new("spec/fixtures/test_acls")
  end

  describe "#index" do
    context "with an anonymous user" do
      it "redirects to login" do
        get :index
        expect(response).to be_redirect
      end
    end
  end
end

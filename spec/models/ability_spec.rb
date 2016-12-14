require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  subject { described_class.new current_user }

  let(:file) { FactoryGirl.build :generic_image_with_content,
    edit_groups: ["photostudio"] }
  let(:collection) { FactoryGirl.build :collection }

  let(:editorial) { FactoryGirl.create :editorial_collection }
  let(:object_photography) { FactoryGirl.create :object_photography_collection }
  let(:conservation) { FactoryGirl.create :conservation_collection }
   
  let(:archivist) { FactoryGirl.create(:user, :archivist) }
  let(:conservationist) { FactoryGirl.create(:user, :conservationist) }
  let(:photographer) { FactoryGirl.create(:user, :photographer) }
  
  before(:each) do
    editorial.members += [file]
  end

  describe "for an administrator" do
    let(:administrator) { FactoryGirl.create(:user, :administrator) }
    let(:current_user) { administrator }
    
    it {
      should be_able_to :discover, Collection
      should be_able_to :edit, Collection
      should be_able_to :destroy, Collection

      should be_able_to :edit, GenericFile
      should be_able_to :discover, GenericFile
      should be_able_to :destroy, GenericFile
      should be_able_to :edit, file
 
      should be_able_to :download, ActiveFedora::File
      should be_able_to :download, file.content
    } 
  end
 
  describe "for the photostudio" do
    let(:photographer) { FactoryGirl.create(:user, :photographer) }
    let(:current_user) { photographer }

    it {
      should be_able_to :discover, editorial
      should be_able_to :read, editorial
      should_not be_able_to :edit, editorial
      should be_able_to :download, file.content
    
      should be_able_to :discover, object_photography
      should be_able_to :read, object_photography
      should_not be_able_to :edit, object_photography
    }
  end

  describe "for a conservationist" do
    let(:conservationist) { FactoryGirl.create(:user, :conservationist) }
    let(:current_user) { conservationist }

    it {
      should_not be_able_to :discover, editorial
      should_not be_able_to :read, editorial
      should_not be_able_to :edit, editorial
      should_not be_able_to :download, file.content
    
      should be_able_to :discover, object_photography
      should be_able_to :read, object_photography
      should_not be_able_to :edit, object_photography
    }
   end 
end

module CMA
  module AdminPolicyBehavior
     
    extend ActiveSupport::Concern

    included do
      belongs_to :administrative_collection, 
        class_name: 'AdministrativeCollection',
        predicate: ActiveFedora::RDF::ProjectHydra.isGovernedBy
    end

    #def discover_groups
    #  retrieve_group_acl :discover
    #end
 
    #def read_groups
    #  retrieve_group_acl :read
    #end
   
    #def edit_groups
    #  retrieve_group_acl :edit
    #end

    #def discover_groups= groups
    #  raise NotImplementedError.new("Set group controls on the policy object")
    #end

    #def edit_groups= groups
    #  raise NotImplementedError.new("Set group controls on the policy object")
    #end

    #def read_groups= groups
    #  raise NotImplementedError.new("Set group controls on the policy object")
    #end

    #private
    #  def retrieve_group_acl access
    #    administrative_collection.present? ?
    #      administrative_collection.send("#{access.to_s}_groups") : 
    #      []
    #  end
  end
end

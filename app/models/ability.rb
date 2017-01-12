class Ability
  include Hydra::PolicyAwareAbility
  include Sufia::Ability
  
  # Define any customized permissions here.
  def custom_permissions
    if current_user.groups.include? :admin.to_s
       can [:discover, :read, :edit], AdministrativeCollection
       can [:discover, :read, :edit], Collection
       can [:discover, :read, :edit], GenericFile
       can [:download], FileContentDatastream
       can [:destroy], ActiveFedora::Base
    end
  end

  def download_permissions
    can :download, ActiveFedora::File do |file|
      parent_uri = file.uri.to_s.sub(/\/[^\/]*$/, '')
      parent_id = ActiveFedora::Base.uri_to_id parent_uri
      can? :read, parent_id
    end
  end

  # Override Sufia since all objects are loaded behind the scenes
  def generic_file_abilities
    can :view_share_work, [GenericFile]
    cannot :create, [GenericFile, Collection]
  end
end

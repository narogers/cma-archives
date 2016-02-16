class Ability
  include Hydra::Ability
  include Sufia::Ability

  
  # Define any customized permissions here.
  def custom_permissions
    # Limits deleting objects to admin users
    #
    if current_user.groups.include? :admin.to_s
       can [:discover, :read, :edit], Collection
       can [:discover, :read, :edit], GenericFile
       can [:destroy], ActiveFedora::Base
    end

    # Limits creating new objects to a specific group
    #
    # if user_groups.include? 'special_group'
    #   can [:create], ActiveFedora::Base
    # end
  end
end

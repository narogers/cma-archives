class AdministrativeCollection < Hydra::AdminPolicy
  include ActiveFedora::Noid

  def self.permission_groups
    [:discover, :read, :edit]
  end
end

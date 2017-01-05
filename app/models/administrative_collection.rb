class AdministrativeCollection < Hydra::AdminPolicy
  include Sufia::Noid

  def self.permission_groups
    [:discover, :read, :edit]
  end
end

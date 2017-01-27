class User < ActiveRecord::Base
  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Sufia behaviors. 
  include Sufia::User
  include Sufia::UserUsageStats

  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :ldap_authenticatable

  # Override the groups method to revert back to using the Role Map. A
  # future iteration might rely directly on LDAP but that can wait 
  # until there are more than a dozen users
  def groups
    RoleMapper.roles(self)
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  # Define the batch user here so you don't need to do it when the ingest
  # is happening
  def self.batchuser_key
    "clio-batches"
  end

  def self.audituser_key
    "clio-audits"
  end
end

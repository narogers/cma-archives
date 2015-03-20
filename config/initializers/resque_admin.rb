module Sufia
  class ResqueAdmin
    def self.matches?(request)
      current_user = request.env['warden'].user
      return false if current_user.blank?

      # TODO code a group here that makes sense
      admins = ['nrogers@clevelandart.org', 'smiller@clevelandart.org', 
      	'nkrause@clevelandart.org']
      return admins.include? current_user.name
    end
  end
end

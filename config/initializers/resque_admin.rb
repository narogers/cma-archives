module Sufia
  class ResqueAdmin
    def self.matches?(request)
      current_user = request.env['warden'].user
      return false if current_user.blank?

      return RoleMapper.roles(current_user).include? :admin.to_s
    end
  end
end

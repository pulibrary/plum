module PulUserRoles
  extend ActiveSupport::Concern

  def scanned_resource_creator?
    roles.where(name: 'scanned_resource_creator').exists?
  end

  def campus_patron?
    roles.where(name: 'campus_patron').exists?
  end
end

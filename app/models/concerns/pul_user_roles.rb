module PulUserRoles
  extend ActiveSupport::Concern

  def image_editor?
    roles.where(name: 'image_editor').exists?
  end

  def campus_patron?
    persisted? && provider == "cas"
  end
end

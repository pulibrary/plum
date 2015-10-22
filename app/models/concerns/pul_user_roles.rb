module PulUserRoles
  extend ActiveSupport::Concern

  def curation_concern_creator?
    roles.where(name: 'curation_concern_creator').exists?
  end

  def campus_patron?
    roles.where(name: 'campus_patron').exists?
  end

  def authorized?
    roles.where(name: "authorized").exists?
  end
end

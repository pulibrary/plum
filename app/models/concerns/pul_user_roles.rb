module PulUserRoles
  extend ActiveSupport::Concern

  def curation_concern_creator?
    roles.where(name: 'curation_concern_creator').exists?
  end

  def campus_patron?
    persisted? && provider == "cas"
  end
end

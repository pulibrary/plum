module IuUserRoles
  extend ActiveSupport::Concern

  def image_editor?
    roles.where(name: 'image_editor').exists?
  end

  def editor?
    roles.where(name: 'editor').exists?
  end

  def fulfiller?
    roles.where(name: 'fulfiller').exists?
  end

  def curator?
    roles.where(name: 'curator').exists?
  end

  def campus_patron?
    persisted? && provider == "cas"
  end

  def music_patron?
    campus_patron? && (Plum.config[:authorized_ldap_groups].blank? || authorized_ldap_member?)
  end

  def anonymous?
    !persisted?
  end
end

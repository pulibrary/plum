module PulUserRoles
  extend ActiveSupport::Concern

  def scanned_book_creator?
    roles.where(name: 'scanned_book_creator').exists?
  end

  def campus_patron?
    roles.where(name: 'campus_patron').exists?
  end
end

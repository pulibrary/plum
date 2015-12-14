class Ability
  include Hydra::Ability
  include CurationConcerns::Ability
  # Define any customized permissions here.
  def custom_permissions
    alias_action :pdf, :show, :manifest, to: :read
    admin_permissions if current_user.admin?
    curation_concern_creator_permissions if current_user.curation_concern_creator?
    campus_patron_permissions if current_user.campus_patron?
  end

  # Abilities that should only be granted to admin users
  def admin_permissions
    can [:create, :read, :add_user, :remove_user, :index], Role
    can [:manage], curation_concerns
    can [:manage], Collection
    can [:manage], FileSet
  end

  # Abilities that should be granted to technicians
  def curation_concern_creator_permissions
    # Do not allow creators to destroy what they make.
    can [:create, :read, :edit, :update, :publish], curation_concerns
    can [:bulk_edit], ScannedResource
    can [:create, :read, :edit, :update, :publish], FileSet
    can [:create, :read, :edit, :update, :publish], Collection
  end

  # Abilities that should be granted to patron
  def campus_patron_permissions
  end

  private

    def curation_concerns
      CurationConcerns.config.curation_concerns
    end
end

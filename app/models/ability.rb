class Ability
  include Hydra::Ability
  include CurationConcerns::Ability
  # Define any customized permissions here.
  def custom_permissions
    alias_action :pdf, :show, to: :read
    admin_permissions if current_user.admin?
    curation_concern_creator_permissions if current_user.curation_concern_creator?
    campus_patron_permissions if current_user.campus_patron?
    manifest_permissions
  end

  # Abilities that should only be granted to admin users
  def admin_permissions
    can [:create, :read, :add_user, :remove_user, :index], Role
    can [:manage], curation_concerns
    can [:manage], FileSet
  end

  def manifest_permissions
    can [:manifest], :all
  end

  # Abilities that should be granted to technicians
  def curation_concern_creator_permissions
    can [:manage], curation_concerns
    can [:manage], FileSet
  end

  # Abilities that should be granted to patron
  def campus_patron_permissions
    # Should be able to read access rights "Princeton Only"
    can :read, curation_concerns
  end

  private

    def curation_concerns
      CurationConcerns.config.curation_concerns
    end
end

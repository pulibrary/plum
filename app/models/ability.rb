class Ability
  include Hydra::Ability
  include CurationConcerns::Ability
  # Define any customized permissions here.
  def custom_permissions
    alias_action :pdf, :show, :manifest, to: :read
    admin_permissions if current_user.admin?
    image_editor_permissions if current_user.image_editor?
    editor_permissions if current_user.editor?
    fulfiller_permissions if current_user.fulfiller?
    campus_patron_permissions if current_user.campus_patron?
  end

  # Abilities that should only be granted to admin users
  def admin_permissions
    can [:manage], :all
  end

  # Abilities that should be granted to technicians
  def image_editor_permissions
    can [:create, :read, :edit, :update, :publish], curation_concerns
    can [:bulk_edit, :save_structure], ScannedResource
    can [:create, :read, :edit, :update, :publish, :download], FileSet
    can [:create, :read, :edit, :update, :publish], Collection

    # do not allow completing resources
    cannot [:complete], curation_concerns

    # only allow deleting for own objects, without ARKs
    can [:destroy], FileSet, depositor: current_user.uid
    can [:destroy], curation_concerns, depositor: current_user.uid, identifier: nil
  end

  def editor_permissions
    can [:read, :edit, :update], curation_concerns
    can [:bulk_edit, :save_structure], ScannedResource
    can [:read, :edit, :update], FileSet
    can [:read, :edit, :update], Collection

    # do not allow completing resources
    cannot [:complete], curation_concerns
  end

  def fulfiller_permissions
    can [:read], curation_concerns
    can [:read, :download], FileSet
    can [:read], Collection
  end

  # Abilities that should be granted to patron
  def campus_patron_permissions
    can [:flag], curation_concerns
  end

  private

    def curation_concerns
      CurationConcerns.config.curation_concerns
    end
end

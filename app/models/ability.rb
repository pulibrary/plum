class Ability
  include Hydra::Ability
  include CurationConcerns::Ability

  # Define any customized permissions here.
  def custom_permissions
    alias_action :pdf, :show, :manifest, to: :read
    roles.each do |role|
      send "#{role}_permissions" if current_user.send "#{role}?"
    end
  end

  # Abilities that should only be granted to admin users
  def admin_permissions
    can [:manage], :all
  end

  # Abilities that should be granted to technicians
  def image_editor_permissions
    can [:create, :read, :edit, :update, :publish], curation_concerns
    can [:bulk_edit, :save_structure], ScannedResource
    can [:bulk_edit, :save_structure], MultiVolumeWork
    can [:create, :read, :edit, :update, :publish, :download], FileSet
    can [:create, :read, :edit, :update, :publish], Collection

    # do not allow completing resources
    cannot [:complete], curation_concerns

    # only allow deleting for own objects, without ARKs
    can [:destroy], FileSet, depositor: current_user.uid
    can [:destroy], curation_concerns, depositor: current_user.uid
    cannot [:destroy], curation_concerns do |obj|
      !obj.identifier.nil?
    end
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

  def curator_permissions
    can [:read], curation_concerns
    can [:read], FileSet
    can [:read], Collection

    # do not allow viewing pending resources
    cannot [:read], curation_concerns, state: 'pending'
  end

  # Abilities that should be granted to patron
  def campus_patron_permissions
    anonymous_permissions
    can [:flag], curation_concerns
  end

  def anonymous_permissions
    # do not allow viewing incomplete resources
    cannot [:read], curation_concerns, state: 'pending'
    cannot [:read], curation_concerns, state: 'metadata_review'
    cannot [:read], curation_concerns, state: 'final_review'
    cannot [:read], curation_concerns, state: 'takedown'
  end

  private

    def curation_concerns
      CurationConcerns.config.curation_concerns
    end

    def roles
      ['anonymous', 'campus_patron', 'curator', 'fulfiller', 'editor', 'image_editor', 'admin']
    end
end

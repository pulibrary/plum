class Ability
  include Hydra::Ability
  # include Hyrax::Ability
  # include GeoConcerns::Ability

  # Define any customized permissions here.
  def custom_permissions
    alias_action :show, :manifest, to: :read
    alias_action :color_pdf, :pdf, :edit, to: :modify
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
    can [:read, :create, :modify, :update, :publish], curation_concerns
    can [:file_manager, :save_structure], ScannedResource
    can [:file_manager, :save_structure], MultiVolumeWork
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
    can [:read, :modify, :update], curation_concerns
    can [:file_manager, :save_structure], ScannedResource
    can [:file_manager, :save_structure], MultiVolumeWork
    can [:read, :edit, :update], FileSet
    can [:read, :edit, :update], Collection

    # do not allow completing resources
    cannot [:complete], curation_concerns

    curation_concern_read_permissions
  end

  def fulfiller_permissions
    can [:read], curation_concerns
    can [:read, :download], FileSet
    can [:read], Collection
    curation_concern_read_permissions
  end

  def curator_permissions
    can [:read], curation_concerns
    can [:read], FileSet
    can [:read], Collection

    # do not allow viewing pending resources
    curation_concern_read_permissions
  end

  # Abilities that should be granted to patron
  def campus_patron_permissions
    anonymous_permissions
  end

  def anonymous_permissions
    # do not allow viewing incomplete resources
    curation_concern_read_permissions
  end

  def curation_concern_read_permissions
    cannot [:read], curation_concerns do |curation_concern|
      !readable_concern?(curation_concern)
    end
    can :pdf, (curation_concerns + [ScannedResourceShowPresenter]) do |curation_concern|
      ["color", "gray"].include?(Array(curation_concern.pdf_type).first)
    end
    can :color_pdf, (curation_concerns + [ScannedResourceShowPresenter]) do |curation_concern|
      curation_concern.pdf_type == ["color"]
    end
  end

  def readable_concern?(curation_concern)
    !unreadable_states.include?(curation_concern.workflow_state)
  end

  def unreadable_states
    if current_user.curator?
      %w(pending)
    elsif universal_reader?
      []
    else
      %w(pending metadata_review final_review takedown)
    end
  end

  private

    def universal_reader?
      current_user.curator? || current_user.image_editor? || current_user.fulfiller? || current_user.editor? || current_user.admin?
    end

    def curation_concerns
      Hyrax.config.curation_concerns
    end

    def roles
      ['anonymous', 'campus_patron', 'curator', 'fulfiller', 'editor', 'image_editor', 'admin']
    end
end

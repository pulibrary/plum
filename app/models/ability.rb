class Ability
  include Hydra::Ability
  include CurationConcerns::Ability
  # self.ability_logic += [:everyone_can_create_curation_concerns]

  # Taken from https://github.com/KelvinSmithLibrary/absolute/blob/master/app/models/ability.rb

  # Define any customized permissions here.
  def custom_permissions
    alias_action :pdf, :show, to: :read
    admin_permissions if current_user.admin?
    scanned_resource_creator_permissions if current_user.scanned_resource_creator?
    campus_patron_permissions if current_user.campus_patron?
    manifest_permissions
  end

  # Abilities that should only be granted to admin users
  def admin_permissions
    can [:create, :read, :add_user, :remove_user, :index], Role
    can [:create, :read, :edit, :update, :destroy, :publish], curation_concerns
    can [:create, :read, :edit, :update, :destroy, :publish], GenericFile
    # can :create, Collection
    can [:destroy], ActiveFedora::Base
    # can :manage, Resque
    # can :manage, :bulk_update
  end

  def manifest_permissions
    can [:manifest], :all
  end

  # Abilities that should be granted to technicians
  def scanned_resource_creator_permissions
    can [:create, :read, :edit, :update, :publish], ScannedResource
    can [:create, :read, :edit, :update, :publish], GenericFile
  end

  # Abilities that should be granted to patron
  def campus_patron_permissions
    # Should ne able to read access rights "Princeton Only"
    can :read, curation_concerns
  end

  private

    def curation_concerns
      CurationConcerns.config.curation_concerns
    end
end

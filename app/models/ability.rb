class Ability
  include Hydra::Ability
  include CurationConcerns::Ability
  # self.ability_logic += [:everyone_can_create_curation_concerns]

  # Taken from https://github.com/KelvinSmithLibrary/absolute/blob/master/app/models/ability.rb

  # Define any customized permissions here.
  def custom_permissions
    admin_permissions if current_user.admin?
    scanned_book_creator_permissions if current_user.scanned_book_creator?
    campus_patron_permissions if current_user.campus_patron?
  end

  # Abilities that should only be granted to admin users
  def admin_permissions
    can [:create, :show, :add_user, :remove_user, :index], Role
    can [:create, :read, :edit, :update, :destroy, :publish], curation_concerns
    can [:create, :read, :edit, :update, :destroy, :publish], GenericFile
    # can :create, Collection
    can [:destroy], ActiveFedora::Base
    # can :manage, Resque
    # can :manage, :bulk_update
  end

  # Abilities that should be granted to technicians
  def scanned_book_creator_permissions
    can [:create, :read, :edit, :update, :publish], ScannedBook
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

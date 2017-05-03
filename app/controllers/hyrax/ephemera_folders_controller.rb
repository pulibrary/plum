# Generated via
#  `rails generate hyrax:work EphemeraFolder`

module Hyrax
  class EphemeraFoldersController < Hyrax::HyraxController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = EphemeraFolder
    self.show_presenter = EphemeraFolderPresenter
    skip_load_and_authorize_resource only: ::SearchBuilder.show_actions
  end
end

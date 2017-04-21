# Generated via
#  `rails generate hyrax:work EphemeraFolder`

module Hyrax
  class EphemeraFoldersController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = EphemeraFolder
    self.show_presenter = EphemeraFolderPresenter
  end
end

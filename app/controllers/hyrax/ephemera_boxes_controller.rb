# Generated via
#  `rails generate hyrax:work EphemeraBox`

module Hyrax
  class EphemeraBoxesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = EphemeraBox
  end
end

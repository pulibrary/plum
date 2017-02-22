class Hyrax::VectorWorksController < ApplicationController
  include Hyrax::WorksControllerBehavior
  include Hyrax::ParentContainer
  include GeoWorks::VectorWorksControllerBehavior
  include GeoWorks::GeoblacklightControllerBehavior
  include Hyrax::GeoMessengerBehavior
  self.curation_concern_type = VectorWork

  def show_presenter
    VectorWorkShowPresenter
  end
end

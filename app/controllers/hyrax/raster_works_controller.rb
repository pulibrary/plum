class Hyrax::RasterWorksController < ApplicationController
  include Hyrax::CurationConcernController
  include Hyrax::ParentContainer
  # include GeoConcerns::RasterWorksControllerBehavior
  # include GeoConcerns::GeoblacklightControllerBehavior
  include Hyrax::GeoMessengerBehavior
  self.curation_concern_type = RasterWork

  def show_presenter
    RasterWorkShowPresenter
  end
end

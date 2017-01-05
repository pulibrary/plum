class CurationConcerns::RasterWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  include CurationConcerns::ParentContainer
  include GeoConcerns::RasterWorksControllerBehavior
  include GeoConcerns::GeoblacklightControllerBehavior
  include CurationConcerns::GeoMessengerBehavior
  self.curation_concern_type = RasterWork

  def show_presenter
    RasterWorkShowPresenter
  end
end

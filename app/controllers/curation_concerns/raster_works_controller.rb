class CurationConcerns::RasterWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  include CurationConcerns::ParentContainer
  include GeoConcerns::RasterWorksControllerBehavior
  include GeoConcerns::GeoblacklightControllerBehavior
  include GeoConcerns::MessengerBehavior
  self.curation_concern_type = RasterWork

  def show_presenter
    RasterWorkShowPresenter
  end
end

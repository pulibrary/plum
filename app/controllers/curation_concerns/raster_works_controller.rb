class CurationConcerns::RasterWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  include CurationConcerns::ParentContainer
  include GeoConcerns::RasterWorksControllerBehavior
  include GeoConcerns::GeoblacklightControllerBehavior
  include GeoConcerns::MessengerBehavior
  include CurationConcerns::Flagging
  self.curation_concern_type = RasterWork

  def show_presenter
    RasterWorkShowPresenter
  end
end

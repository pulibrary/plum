class CurationConcerns::VectorWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  include CurationConcerns::ParentContainer
  include GeoConcerns::VectorWorksControllerBehavior
  include GeoConcerns::GeoblacklightControllerBehavior
  include CurationConcerns::GeoMessengerBehavior
  include CurationConcerns::Flagging
  self.curation_concern_type = VectorWork

  def show_presenter
    VectorWorkShowPresenter
  end
end

class Hyrax::VectorWorksController < ApplicationController
  include Hyrax::CurationConcernController
  include Hyrax::ParentContainer
  # include GeoConcerns::VectorWorksControllerBehavior
  # include GeoConcerns::GeoblacklightControllerBehavior
  include Hyrax::GeoMessengerBehavior
  self.curation_concern_type = VectorWork

  def show_presenter
    VectorWorkShowPresenter
  end
end

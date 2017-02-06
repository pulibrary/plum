class Hyrax::ImageWorksController < ApplicationController
  include Hyrax::CurationConcernController
  include GeoConcerns::ImageWorksControllerBehavior
  include GeoConcerns::GeoblacklightControllerBehavior
  include Hyrax::GeoMessengerBehavior
  self.curation_concern_type = ImageWork

  def show_presenter
    ImageWorkShowPresenter
  end
end

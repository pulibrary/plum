class Hyrax::ImageWorksController < Hyrax::GeoWorksController
  include GeoWorks::ImageWorksControllerBehavior
  include Hyrax::Manifest
  include Hyrax::RemoteMetadata
  self.curation_concern_type = ImageWork

  def show_presenter
    ImageWorkShowPresenter
  end
end

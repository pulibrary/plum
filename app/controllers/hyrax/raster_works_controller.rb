class Hyrax::RasterWorksController < Hyrax::GeoWorksController
  include Hyrax::ParentContainer
  include GeoWorks::RasterWorksControllerBehavior
  include Hyrax::GeoMessengerBehavior
  self.curation_concern_type = RasterWork

  def show_presenter
    RasterWorkShowPresenter
  end
end

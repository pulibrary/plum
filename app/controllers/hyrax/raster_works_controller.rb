class Hyrax::RasterWorksController < Hyrax::GeoWorksController
  include Hyrax::ParentContainer
  include GeoWorks::RasterWorksControllerBehavior
  self.curation_concern_type = RasterWork

  def show_presenter
    RasterWorkShowPresenter
  end
end

class Hyrax::VectorWorksController < Hyrax::GeoWorksController
  include Hyrax::ParentContainer
  include GeoWorks::VectorWorksControllerBehavior
  self.curation_concern_type = VectorWork

  def show_presenter
    VectorWorkShowPresenter
  end
end

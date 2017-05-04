class Hyrax::MapSetsController < Hyrax::HyraxController
  include Hyrax::RemoteMetadata
  self.curation_concern_type = MapSet

  def show_presenter
    MapSetShowPresenter
  end
end

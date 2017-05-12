class Hyrax::MapSetsController < Hyrax::HyraxController
  include Hyrax::RemoteMetadata
  self.curation_concern_type = MapSet
  skip_load_and_authorize_resource only: SearchBuilder.show_actions

  def show_presenter
    MapSetShowPresenter
  end
end

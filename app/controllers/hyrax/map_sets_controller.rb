# frozen_string_literal: true
class Hyrax::MapSetsController < Hyrax::HyraxController
  include Hyrax::RemoteMetadata
  include GeoWorks::GeoblacklightControllerBehavior
  include Hyrax::GeoEventsBehavior

  self.curation_concern_type = MapSet
  skip_load_and_authorize_resource only: SearchBuilder.show_actions

  def show_presenter
    MapSetShowPresenter
  end

  private

    def document_class
      Discovery::GeoblacklightDocument
    end
end

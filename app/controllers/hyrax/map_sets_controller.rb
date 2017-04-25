# Generated via
#  `rails generate hyrax:work MapSet`

module Hyrax
  class MapSetsController < Hyrax::HyraxController
    self.curation_concern_type = MapSet

    def show_presenter
      MapSetShowPresenter
    end
  end
end

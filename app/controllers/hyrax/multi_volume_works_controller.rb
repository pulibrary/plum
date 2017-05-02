# Generated via
#  `rails generate hyrax:work MultiVolumeWork`
class Hyrax::MultiVolumeWorksController < Hyrax::HyraxController
  include Hyrax::RemoteMetadata
  self.curation_concern_type = MultiVolumeWork
  skip_load_and_authorize_resource only: SearchBuilder.show_actions

  def show_presenter
    MultiVolumeWorkShowPresenter
  end
end

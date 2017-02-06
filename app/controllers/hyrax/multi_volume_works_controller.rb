# Generated via
#  `rails generate curation_concerns:work MultiVolumeWork`
class Hyrax::MultiVolumeWorksController < Hyrax::HyraxController
  self.curation_concern_type = MultiVolumeWork
  skip_load_and_authorize_resource only: SearchBuilder.show_actions

  def show_presenter
    MultiVolumeWorkShowPresenter
  end
end

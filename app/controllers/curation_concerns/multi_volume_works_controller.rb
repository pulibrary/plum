# Generated via
#  `rails generate curation_concerns:work MultiVolumeWork`
class CurationConcerns::MultiVolumeWorksController < CurationConcerns::CurationConcernsController
  set_curation_concern_type MultiVolumeWork
  skip_load_and_authorize_resource only: [:show, :manifest]

  def show_presenter
    MultiVolumeWorkShowPresenter
  end
end

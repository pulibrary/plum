# Generated via
#  `rails generate curation_concerns:work ScannedResource`

class CurationConcerns::ScannedResourcesController < CurationConcerns::CurationConcernsController
  set_curation_concern_type ScannedResource
  skip_load_and_authorize_resource only: [:show, :manifest]

  def show_presenter
    ScannedResourceShowPresenter
  end

  def pdf
    actor.generate_pdf
    redirect_to main_app.download_path(curation_concern, file: 'pdf')
  end
end

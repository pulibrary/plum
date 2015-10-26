# Generated via
#  `rails generate curation_concerns:work ScannedResource`

class CurationConcerns::ScannedResourcesController < CurationConcerns::CurationConcernsController
  include CurationConcerns::ParentContainer
  set_curation_concern_type ScannedResource
  skip_load_and_authorize_resource only: [:show, :manifest]

  def create
    super

    return unless parent_id
    parent = ActiveFedora::Base.find(parent_id, cast: true)
    parent.ordered_members << curation_concern.reload
    parent.save
    curation_concern.update_index
  end

  def show_presenter
    ScannedResourceShowPresenter
  end

  def pdf
    actor.generate_pdf
    redirect_to main_app.download_path(curation_concern, file: 'pdf')
  end
end

# Generated via
#  `rails generate curation_concerns:work ScannedResource`

class CurationConcerns::ScannedResourcesController < CurationConcerns::CurationConcernsController
  include CurationConcerns::ParentContainer
  set_curation_concern_type ScannedResource
  skip_load_and_authorize_resource only: SearchBuilder.show_actions

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
    ScannedResourcePDF.new(presenter).render(pdf_path)
    redirect_to main_app.download_path(presenter, file: 'pdf')
  end

  def form_class
    CurationConcerns::ScannedResourceForm
  end

  private

    def pdf_path
      PairtreeDerivativePath.derivative_path_for_reference(presenter, 'pdf')
    end

    def after_create_response
      send_record_created
      dest = parent_id.nil? ? polymorphic_path([main_app, curation_concern]) : main_app.curation_concerns_member_scanned_resource_path(parent_id, curation_concern)
      respond_to do |wants|
        wants.html { redirect_to dest }
        wants.json { render :show, status: :created, location: dest }
      end
    end
end

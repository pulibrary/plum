# Generated via
#  `rails generate curation_concerns:work ScannedResource`

class CurationConcerns::ScannedResourcesController < CurationConcerns::CurationConcernsController
  include CurationConcerns::ParentContainer
  self.curation_concern_type = ScannedResource
  skip_load_and_authorize_resource only: SearchBuilder.show_actions
  before_action :authorize_pdf, only: [:pdf]

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
    ScannedResourcePDF.new(presenter, quality: params[:pdf_quality]).render(pdf_path)
    redirect_to main_app.download_path(presenter, file: pdf_type)
  end

  def form_class
    CurationConcerns::ScannedResourceForm
  end

  private

    def authorize_pdf
      return unless params[:pdf_quality] == "color"
      return if can?(:color_pdf, ScannedResource)
      raise CanCan::AccessDenied.new(nil, params[:action].to_sym)
    end

    def pdf_path
      PairtreeDerivativePath.derivative_path_for_reference(presenter, pdf_type)
    end

    def pdf_type
      "#{params[:pdf_quality]}-pdf"
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

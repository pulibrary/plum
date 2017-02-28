# Generated via
#  `rails generate hyrax:work ScannedResource`

class Hyrax::ScannedResourcesController < Hyrax::HyraxController
  self.curation_concern_type = ScannedResource
  skip_load_and_authorize_resource only: SearchBuilder.show_actions
  before_action :authorize_pdf, only: [:pdf]

  def show_presenter
    ScannedResourceShowPresenter
  end

  def pdf
    ScannedResourcePDF.new(presenter, quality: params[:pdf_quality]).render(pdf_path)
    redirect_to hyrax.download_path(presenter, file: pdf_type)
  end

  def form_class
    Hyrax::ScannedResourceForm
  end

  private

    def authorize_pdf
      if params[:pdf_quality] == "color"
        authorize_color_pdf
      else
        authorize_gray_pdf
      end
    end

    def authorize_color_pdf
      return if can?(:color_pdf, presenter)
      raise CanCan::AccessDenied.new(nil, params[:action].to_sym)
    end

    def authorize_gray_pdf
      return if can?(:pdf, presenter)
      raise CanCan::AccessDenied.new(nil, params[:action].to_sym)
    end

    def pdf_path
      PairtreeDerivativePath.derivative_path_for_reference(presenter, pdf_type)
    end

    def pdf_type
      "#{params[:pdf_quality]}-pdf"
    end
end

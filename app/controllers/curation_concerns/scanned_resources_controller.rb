# Generated via
#  `rails generate curation_concerns:work ScannedResource`

class CurationConcerns::ScannedResourcesController < ApplicationController
  include CurationConcerns::CurationConcernController
  set_curation_concern_type ScannedResource
  skip_load_and_authorize_resource only: [:show, :manifest]

  def pdf
    actor.generate_pdf
    redirect_to main_app.download_path(curation_concern, file: 'pdf')
  end

  def curation_concern
    if wants_to_update_remote_metadata?
      decorated_concern
    else
      @curation_concern
    end
  end

  def manifest
    respond_to do |f|
      f.json do
        render json: manifest_builder
      end
    end
  end

  private

    def presenter
      @presenter ||=
        begin
          _, document_list = search_results(params, CatalogController.search_params_logic)
          curation_concern = document_list.first
          raise CanCan::AccessDenied.new(nil, :manifest) unless curation_concern
          @presenter = show_presenter.new(curation_concern, current_ability)
        end
    end

    def manifest_builder
      ManifestBuilder.new(presenter)
    end

    def show_presenter
      ScannedResourceShowPresenter
    end

    def decorated_concern
      decorator.new(@curation_concern)
    end

    def decorator
      UpdatesMetadata
    end

    def wants_to_update_remote_metadata?
      params[:action] == "create" || params[:refresh_remote_metadata]
    end
end

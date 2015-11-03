class CurationConcerns::CurationConcernsController < ApplicationController
  include CurationConcerns::CurationConcernController

  def create
    super
  rescue StandardError => err
    metadata_id = params[curation_concern_name]['source_metadata_identifier']
    logger.debug "Error retrieving metadata for #{metadata_id}: #{err}"
    flash[:alert] = "Error retrieving metadata for '#{metadata_id}'"
    render :new, status: 500
  end

  def curation_concern_name
    curation_concern.class.name.underscore
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
          _, document_list = search_results(params, CatalogController.search_params_logic + [:find_one])
          curation_concern = document_list.first
          raise CanCan::AccessDenied.new(nil, :manifest) unless curation_concern
          @presenter = show_presenter.new(curation_concern, current_ability)
        end
    end

    def manifest_builder
      ManifestBuilder.new(presenter)
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

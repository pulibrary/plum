# Generated via
#  `rails generate curation_concerns:work ScannedBook`

class CurationConcerns::ScannedBooksController < ApplicationController
  include CurationConcerns::CurationConcernController
  set_curation_concern_type ScannedBook

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

    def manifest_builder
      ManifestBuilder.new(@curation_concern)
    end

    def show_presenter
      ScannedBookShowPresenter
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

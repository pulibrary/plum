class Hyrax::GeoWorksController < ApplicationController
  include Hyrax::WorksControllerBehavior
  include Hyrax::BreadcrumbsForWorks
  include GeoWorks::GeoblacklightControllerBehavior
  include Hyrax::GeoEventsBehavior

  def geoblacklight
    respond_to do |f|
      f.json do
        render json: builder
      end
    end
  end

  private

    def decorator
      CompositeDecorator.new(NullDecorator)
    end

    def document_class
      Discovery::GeoblacklightDocument
    end

    def curation_concern
      @decorated_concern ||=
        begin
          @curation_concern = decorator.new(@curation_concern)
        end
    end

    def builder
      Rails.cache.fetch("geoblacklight/#{presenter.id}/#{ResourceIdentifier.new(presenter.id)}") do
        GeoWorks::Discovery::DocumentBuilder.new(presenter, document_class.new).to_json
      end
    end
end

class Hyrax::GeoWorksController < ApplicationController
  include Hyrax::WorksControllerBehavior
  include Hyrax::BreadcrumbsForWorks
  include GeoWorks::GeoblacklightControllerBehavior
  include Hyrax::GeoMessengerBehavior

  private

    def decorator
      CompositeDecorator.new(NullDecorator)
    end

    def curation_concern
      @decorated_concern ||=
        begin
          @curation_concern = decorator.new(@curation_concern)
        end
    end
end

module Hyrax
  module GeoEventsBehavior
    extend ActiveSupport::Concern

    def destroy
      geo_works_events_generator.record_deleted(geo_work)
      super
    end

    def after_update_response
      super
      return unless curation_concern.workflow_state == 'complete'
      geo_works_events_generator.record_updated(geo_work)
    end

    def geo_works_events_generator
      @geo_works_events_generator ||= GeoWorks::EventsGenerator.new
    end

    def geo_work
      doc = ::SolrDocument.new(curation_concern.to_solr)
      show_presenter.new(doc, current_ability, request)
    end
  end
end

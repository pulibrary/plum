module Hyrax
  module GeoFileSetEventsBehavior
    extend ActiveSupport::Concern

    def create
      super
      return unless curation_concern.parent.workflow_state == 'complete'
      geo_works_events_generator.record_updated(geo_work)
    end

    def destroy
      parent_workflow_state = curation_concern.parent.workflow_state
      parent_work = geo_work
      super
      return unless parent_workflow_state == 'complete'
      geo_works_events_generator.record_updated(parent_work)
    end

    def geo_works_events_generator
      @geo_works_events_generator ||= GeoWorks::EventsGenerator.new
    end

    def geo_work
      doc = ::SolrDocument.new(curation_concern.parent.to_solr)
      geo_work_show_presenter_class.new(doc, current_ability, request)
    end

    def geo_work_show_presenter_class
      ::DynamicShowPresenter.new
    end
  end
end

# frozen_string_literal: true
module GeoWorks
  module TriggerUpdateEvents
    def self.call(geo_work)
      presenter_class = ::DynamicShowPresenter.new
      presenter = presenter_class.new(SolrDocument.new(geo_work.to_solr), nil)
      GeoWorks::EventsGenerator.new.record_updated(presenter)
    end
  end
end

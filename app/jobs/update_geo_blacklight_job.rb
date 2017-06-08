class UpdateGeoBlacklightJob < ApplicationJob
  queue_as :ingest

  # @param [String] Identifier of geo work
  # @param [String] Model name of geo work
  def perform(work_id, model_name)
    klass = model_name.constantize
    work = klass.search_with_conditions(id: work_id).first
    return unless work
    doc = SolrDocument.new(work)
    geo_work = show_presenter_class.new(doc, nil, nil)
    geo_works_events_generator.record_updated(geo_work)
  end

  def show_presenter_class
    DynamicShowPresenter.new
  end

  def geo_works_events_generator
    GeoWorks::EventsGenerator.new
  end
end

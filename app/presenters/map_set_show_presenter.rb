class MapSetShowPresenter < HyraxShowPresenter
  include PlumAttributes
  delegate :spatial, :temporal, :issued, :coverage, :provenance, :layer_modified, to: :solr_document

  def external_metadata_file_set_presenters
    # filter for external metadata files
    file_set_presenters.select do |member|
      GeoWorks::MetadataFormatService.include? member.solr_document.fetch(:geo_mime_type_tesim, [])[0]
    end
  end

  def attribute_to_html(field, options = {})
    if field == :coverage
      GeoWorks::CoverageRenderer.new(field, send(field), options).render
    else
      super field, options
    end
  end
end

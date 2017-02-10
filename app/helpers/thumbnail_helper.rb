module ThumbnailHelper
  include Blacklight::CatalogHelperBehavior

  # Generates a thumbnail path for the various work and fileset types.
  # @param document [SolrDocument, ShowPresenter] an object's solr document or show presenter
  # @param image_options [Hash]
  # @return [String] thumbnail tag
  def plum_thumbnail_path(document, image_options = {})
    value = send(plum_thumbnail_method(document), document, image_options)
    link_to_document document, value if value
  end

  # Gets the correct thumbnail path generation method
  # for work or fileset type.
  # @param document [SolrDocument, ShowPresenter] an object's solr document or show presenter
  # @return [Symbol]
  def plum_thumbnail_method(document)
    document = document.solr_document if document.respond_to?(:solr_document)
    class_name = document.to_model.class_name

    if document['geo_mime_type_tesim']
      # geo fileset
      :geo_concerns_thumbnail_path
    elsif ["ImageWork", "RasterWork", "VectorWork"].include?(class_name)
      # geo work
      :geo_concerns_thumbnail_path
    else
      :iiif_thumbnail_path
    end
  end

  def geo_concerns_thumbnail_path(document, image_options = {})
    url = thumbnail_url(document)
    image_tag url, image_options if url.present?
  end

  def iiif_thumbnail_path(document, image_options = {})
    return unless document.thumbnail_id
    url = IIIFPath.new(document.thumbnail_id).thumbnail
    image_tag url, image_options if url.present?
  end
end

class ImageWorkShowPresenter < GeoWorks::ImageWorkShowPresenter
  include PlumAttributes
  delegate :viewing_hint, :viewing_direction, :logical_order, :logical_order_object, :ocr_language,
           :cartographic_projection, :cartographic_scale, :alternative, :edition, :pdf_type,
           :contents, to: :solr_document
end

class ImageWorkShowPresenter < GeoWorks::ImageWorkShowPresenter
  include PlumAttributes
  delegate :viewing_hint, :viewing_direction, :logical_order, :logical_order_object, :ocr_language, to: :solr_document
end

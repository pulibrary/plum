# frozen_string_literal: true
class ImageWorkShowPresenter < GeoWorks::ImageWorkShowPresenter
  include PlumAttributes
  delegate :viewing_hint, :viewing_direction, :logical_order, :logical_order_object, :ocr_language,
           :cartographic_projection, :cartographic_scale, :alternative, :edition, :pdf_type,
           :contents, :workflow_state, to: :solr_document

  def member_presenter_factory
    ::EfficientMemberPresenterFactory.new(solr_document, current_ability, request)
  end
end

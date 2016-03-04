module IiifHelper
  def iiif_thumbnail_path(document, image_options = {})
    return unless document.thumbnail_id
    url = IIIFPath.new(document.thumbnail_id).thumbnail
    image_tag url, image_options if url.present?
  end
end

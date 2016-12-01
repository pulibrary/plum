module GeoConcernsHelper
  def geo_concerns_thumbnail_path(document, image_options = {})
    url = thumbnail_url(document)
    image_tag url, image_options if url.present?
  end
end

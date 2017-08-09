module SearchHelper
  def annotation_url(id, num = 0)
    "urn:pmp:#{id}_#{num}"
  end

  def manifest_canvas_on_xywh(id, xywh)
    Plum.config[:iiif_url] + "/#{id}/#xywh=#{xywh}"
  end
end

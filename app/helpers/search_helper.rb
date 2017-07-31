module SearchHelper
  def annotation_url(id, num = 0)
    "urn:pmp:#{id}_#{num}"
  end

  def manifest_canvas_on_xywh(id, xywh)
    "http://localhost:3000/#{id}/#xywh=#{xywh}"
  end
end

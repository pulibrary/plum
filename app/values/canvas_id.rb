class CanvasID
  attr_reader :id, :parent_path, :parent_id
  def initialize(id, parent_path, parent_id)
    @id = id
    @parent_path = parent_path
    @parent_id = parent_id
  end

  def to_s
    "http://#{Rails.application.routes.default_url_options[:host]}/iiif/#{parent_id}/canvas/#{id}"
  end
end

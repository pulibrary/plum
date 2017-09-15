class CanvasID
  attr_reader :id, :parent_path

  def initialize(id, parent_path)
    @id = id
    @parent_path = parent_path
  end

  def to_s
    "#{parent_path}/canvas/#{id}"
  end
end

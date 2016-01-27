class HOCRDocument
  class BoundingBox
    attr_reader :bbox_values

    def initialize(bbox_values)
      @bbox_values = bbox_values.map(&:to_i)
    end

    def top_left
      Coordinate.new(bbox_values[0], bbox_values[1])
    end

    def bottom_right
      Coordinate.new(bbox_values[2], bbox_values[3])
    end

    class Coordinate
      attr_reader :x, :y
      def initialize(x, y)
        @x = x
        @y = y
      end
    end
  end
end

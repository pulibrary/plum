class ScannedResourcePDF
  class Canvas
    attr_reader :canvas
    def initialize(canvas)
      @canvas = canvas
    end

    def width
      canvas.resource.width
    end

    def height
      canvas.resource.height
    end

    def url
      canvas.resource.service['@id']
    end
  end
end

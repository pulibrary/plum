class ScannedResourcePDF
  class CanvasDownloader
    attr_reader :canvas
    delegate :width, :height, to: :canvas
    def initialize(canvas)
      @canvas = canvas
    end

    def download
      open(canvas_url, 'rb')
    end

    def layout
      if portrait?
        :portrait
      else
        :landscape
      end
    end

    def portrait?
      canvas.width <= canvas.height
    end

    private

      def canvas_url
        "#{canvas.url}/full/#{max_width},#{max_height}/0/#{quality}.jpg"
      end

      def max_width
        [(Canvas::LETTER_WIDTH * scale_factor).round, canvas.width].min
      end

      def max_height
        [(Canvas::LETTER_HEIGHT * scale_factor).round, canvas.height].min
      end

      def quality
        "gray"
      end

      def scale_factor
        1.5
      end
  end
end

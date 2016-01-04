class ScannedResourcePDF
  class CanvasDownloader
    attr_reader :canvas
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

    private

      def portrait?
        canvas.width <= canvas.height
      end

      def canvas_url
        "#{canvas.url}/full/!#{max_width},#{max_height}/0/#{quality}.jpg"
      end

      def max_width
        792
      end

      def max_height
        792
      end

      def quality
        "gray"
      end
  end
end

class ScannedResourcePDF
  class Renderer
    attr_reader :scanned_resource_pdf, :path
    delegate :manifest_builder, to: :scanned_resource_pdf
    def initialize(scanned_resource_pdf, path)
      @scanned_resource_pdf = scanned_resource_pdf
      @path = Pathname.new(path.to_s)
    end

    def render
      canvas_downloaders.each_with_index do |downloader, index|
        prawn_document.start_new_page layout: downloader.layout if index > 0
        prawn_document.image downloader.download
      end
      FileUtils.mkdir_p(path.dirname)
      prawn_document.render_file(path)
      File.open(path)
    end

    def canvas_images
      @canvas_images ||= manifest_builder.canvases.flat_map(&:images).map do |x|
        Canvas.new(x)
      end
    end

    private

      def canvas_downloaders
        @canvas_images ||= canvas_images.map do |image|
          CanvasDownloader.new(image)
        end
      end

      def prawn_document
        @prawn_document ||= Prawn::Document.new(prawn_options)
      end

      def prawn_options
        default_options = { margin: 0 }
        if canvas_downloaders.first
          default_options[:page_layout] = canvas_downloaders.first.layout
        end
        default_options
      end
  end
end

class ManifestBuilder
  class ThumbnailBuilder
    attr_reader :record, :canvas_builders
    def initialize(record, canvas_builders)
      @record = record
      @canvas_builders = canvas_builders
    end

    def apply(manifest)
      return unless first_canvas
      manifest["thumbnail"] = {
        "@id" => thumbnail_id,
        "service" => image_service
      }
    end

    private

      def image_service
        @image_service ||= first_canvas.images.first["resource"]["service"]
      end

      def first_canvas
        canvas_builders.canvas.first
      end

      def thumbnail_id
        "#{image_service['@id']}/full/#{thumbnail_size}/0/default.jpg"
      end

      def thumbnail_size
        "!200,150"
      end
  end
end

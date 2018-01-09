# frozen_string_literal: true
class ManifestBuilder
  class ThumbnailBuilder
    attr_reader :record, :canvas_builders
    def initialize(record, canvas_builders)
      @record = record
      @canvas_builders = canvas_builders
    end

    def apply(manifest)
      return unless thumbnail_canvas
      manifest["thumbnail"] = {
        "@id" => thumbnail_id,
        "service" => thumbnail_service
      }
    end

    private

      def thumbnail_service
        @thumbnail_service ||= thumbnail_canvas.images.first["resource"]["service"]
      end

      def thumbnail_canvas
        selected_thumbnail_canvas || canvas_builders.canvas.first
      end

      def selected_thumbnail_canvas
        return nil unless record.try(:thumbnail_id)
        canvas_builders.canvas.find { |c| c['@id'].ends_with?(record.thumbnail_id) }
      end

      def thumbnail_id
        "#{thumbnail_service['@id']}/full/#{thumbnail_size}/0/default.jpg"
      end

      def thumbnail_size
        "!200,150"
      end
  end
end

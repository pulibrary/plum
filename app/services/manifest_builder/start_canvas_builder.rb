# frozen_string_literal: true
class ManifestBuilder
  class StartCanvasBuilder
    attr_reader :record, :canvas_builders
    def initialize(record, canvas_builders)
      @record = record
      @canvas_builders = canvas_builders
    end

    def apply(manifest)
      manifest.tap do |m|
        m["startCanvas"] = start_canvas_path if start_canvas_path
      end
    end

    private

      def start_canvas
        record.try(:start_canvas)
      end

      def start_canvas_path
        id_to_canvas[start_canvas]
      end

      def id_to_canvas
        @id_to_canvas ||=
          Hash[
            canvas_builders.record.map(&:id).zip(canvas_builders.path)
          ]
      end
  end
end

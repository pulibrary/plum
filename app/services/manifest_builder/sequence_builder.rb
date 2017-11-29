# frozen_string_literal: true
class ManifestBuilder
  class SequenceBuilder
    attr_reader :parent_path, :canvas_builder, :start_canvas_builder
    def initialize(parent_path, canvas_builder, start_canvas_builder = nil)
      @parent_path = parent_path
      @canvas_builder = canvas_builder
      @start_canvas_builder = start_canvas_builder
    end

    def apply(manifest)
      sequence.viewing_hint = manifest.viewing_hint
      manifest.sequences += [sequence] unless empty?
    end

    def empty?
      sequence.canvases.empty?
    end

    private

      def sequence
        @sequence ||=
          begin
            sequence = IIIF::Presentation::Sequence.new
            sequence["@id"] ||= parent_path.to_s + "/sequence/normal"
            canvas_builder.apply(sequence)
            start_canvas_builder&.apply(sequence)
            sequence
          end
      end
  end
end

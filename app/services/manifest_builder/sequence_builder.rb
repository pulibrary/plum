class ManifestBuilder
  class SequenceBuilder
    attr_reader :parent_path, :canvas_builder
    def initialize(parent_path, canvas_builder)
      @parent_path = parent_path
      @canvas_builder = canvas_builder
    end

    def apply(manifest)
      manifest.sequences += [sequence] unless empty?
    end

    def empty?
      sequence.canvases.length == 0
    end

    private

      def sequence
        @sequence ||=
          begin
            sequence = IIIF::Presentation::Sequence.new
            sequence["@id"] ||= parent_path.to_s + "/sequence/normal"
            canvas_builder.apply(sequence)
            sequence
          end
      end
  end
end

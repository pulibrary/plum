class ManifestBuilder
  class MetadataBuilder
    attr_reader :record
    def initialize(record)
      @record = record
    end

    def apply(manifest)
      manifest.metadata = metadata_objects
    end

    private

      def metadata_objects
        metadata_fields.map do |field|
          if record.respond_to?(field)
            MetadataObject.new(field, record.try(field)).to_h
          end
        end.select(&:present?)
      end

      def metadata_fields
        PlumSchema.display_fields + [:exhibit_id]
      end

      class MetadataObject
        attr_reader :field_name, :values
        def initialize(field_name, values)
          @field_name = field_name
          @values = values
        end

        def label
          renderer.send(:label)
        end

        def to_h
          return {} if values.blank?
          {
            "label" => label,
            "value" => hash_values
          }
        end

        private

          def hash_values
            return values unless values.respond_to?(:each)
            values.map(&:to_s)
          end

          def renderer
            @renderer ||= CurationConcerns::AttributeRenderer.new(field_name, values)
          end
      end
  end
end

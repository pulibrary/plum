class ManifestBuilder
  class MetadataBuilder
    attr_reader :record
    def initialize(record)
      @record = record
    end

    def apply(manifest)
      manifest.metadata = metadata_objects
      manifest
    end

    private

      def metadata_objects
        metadata_fields.map do |field|
          MetadataObject.new(Field.for(record, field)).to_h
        end.select(&:present?)
      end

      class Field
        def self.for(record, field)
          if record.try("#{field}_literals").present?
            self.for(record, "#{field}_literals")
          elsif field.to_s.start_with?("language")
            LanguageField.new(record, field)
          else
            new(record, field)
          end
        end
        attr_reader :record, :field
        def initialize(record, field)
          @record = record
          @field = field
        end

        def values
          record.try(field) || []
        end

        def field_name
          field.to_s.gsub("_literals", "")
        end
      end

      class LanguageField < Field
        def values
          super.map do |value|
            LanguageService.label(value)
          end
        end
      end

      def metadata_fields
        PlumSchema.display_fields + [:exhibit_id, :collection] - [:has_model, :date_created, :identifier, :replaces]
      end

      class MetadataObject
        attr_reader :field
        delegate :values, :field_name, to: :field
        def initialize(field)
          @field = field
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
            values.map do |value|
              if value.is_a?(Hash)
                value
              else
                value.to_s
              end
            end
          end

          def renderer
            @renderer ||= Hyrax::Renderers::AttributeRenderer.new(field_name, values)
          end
      end
  end
end

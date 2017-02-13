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
          if record.respond_to?("#{field}_literals") && record.try("#{field}_literals").present?
            MetadataObject.new(field, record.try("#{field}_literals")).to_h
          elsif record.respond_to?(field)
            MetadataObject.new(field, record.try(field)).to_h
          end
        end.select(&:present?)
      end

      def metadata_fields
        PlumSchema.display_fields + [:exhibit_id, :collection] - [:has_model]
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
            values.map do |value|
              if value.is_a?(Hash)
                value
              else
                wrap_href value.to_s
              end
            end
          end

          def wrap_href(str)
            uri = URI(str.strip)
            if uri.is_a? URI::HTTP
              return "<a href=\"#{uri}\">#{uri}</a>"
            else
              return str
            end
          rescue URI::InvalidURIError
            return str
          end

          def renderer
            @renderer ||= CurationConcerns::Renderers::AttributeRenderer.new(field_name, values)
          end
      end
  end
end

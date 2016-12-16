module GeoConcerns
  module Discovery
    class DocumentBuilder
      class SlugBuilder
        attr_reader :geo_concern

        def initialize(geo_concern)
          @geo_concern = geo_concern
        end

        def build(document)
          document.provenance = provenance
          document.slug = slug
        end

        # Overrides the geo_concerns provenance to match
        # match existing geoblacklight metadata.
        def provenance
          Plum.config[:geoblacklight_provenance]
        end

        # Returns the document slug for use in discovery systems.
        # @return [String] document slug
        def slug
          identifier = geo_concern.identifier || geo_concern.id
          id = identifier.gsub(%r(ark:/\d{5}/), '')
          "#{provenance.parameterize}-#{id}"
        end
      end
    end
  end
end

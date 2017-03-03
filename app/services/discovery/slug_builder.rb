module Discovery
  class SlugBuilder
    attr_reader :geo_work

    def initialize(geo_work)
      @geo_work = geo_work
    end

    def build(document)
      document.provenance = provenance
      document.slug = slug
    end

    # Overrides the geo_works provenance to match
    # match existing geoblacklight metadata.
    def provenance
      Plum.config[:geoblacklight_provenance]
    end

    # Returns the document slug for use in discovery systems.
    # @return [String] document slug
    def slug
      identifier = geo_work.identifier || geo_work.id
      id = identifier.gsub(%r(ark:/\d{5}/), '')
      "#{provenance.parameterize}-#{id}"
    end
  end
end

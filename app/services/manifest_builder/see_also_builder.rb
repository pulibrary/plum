class ManifestBuilder
  class SeeAlsoBuilder
    attr_reader :record
    def initialize(record)
      @record = record
    end

    def apply(manifest)
      return unless record.model_name
      manifest.see_also = see_also_hash
      manifest
    end

    private

      def see_also_hash
        {
          "@id" => helper.polymorphic_url(record, format: :jsonld),
          "format" => "application/ld+json"
        }
      end

      def helper
        ManifestBuilder::ManifestHelper.new
      end
  end
end

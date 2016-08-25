class ManifestBuilder
  class SeeAlsoBuilder
    attr_reader :record
    def initialize(record)
      @record = record
    end

    def apply(manifest)
      manifest.see_also = see_also_hash if bibdata?
      manifest
    end

    private

      def bibdata?
        RemoteRecord.bibdata?(source_metadata_identifier)
      end

      def source_metadata_identifier
        Array(record.try(:source_metadata_identifier)).first
      end

      def see_also_hash
        {
          "@id" => "https://bibdata.princeton.edu/bibliographic/#{source_metadata_identifier}/jsonld", # FIXME: find IU equivalent link
          "format" => "application/ld+json"
        }
      end
  end
end

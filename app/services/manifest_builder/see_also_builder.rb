# frozen_string_literal: true
class ManifestBuilder
  class SeeAlsoBuilder
    attr_reader :record
    def initialize(record)
      @record = record
    end

    def apply(manifest)
      return unless record.model_name
      manifest.see_also = see_also
      manifest
    end

    private

      def see_also
        source_metadata_hash.blank? ? plum_rdf_hash : [plum_rdf_hash, source_metadata_hash]
      end

      def source_metadata_hash
        return unless record.respond_to?(:source_metadata_identifier) && record.source_metadata_identifier
        {
          "@id" => RemoteRecord.source_metadata_url(record.source_metadata_identifier.first),
          "format" => "text/xml"
        }
      end

      def plum_rdf_hash
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

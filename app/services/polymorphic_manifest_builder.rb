class PolymorphicManifestBuilder
  class << self
    ##
    # Constructor for ManifestBuilders of all Works
    # @param [SolrDocument] solr_document the Document for the Work
    # @param args additional arguments passed to the manifest builder
    def new(solr_document, *args)
      manifest = if solr_document.member_presenters.map(&:class).uniq.length > 1
                   sammelband_manifest_builder.new(solr_document, *args)
                 elsif solr_document.is_a? MapSetShowPresenter
                   sammelband_manifest_builder.new(solr_document, *args)
                 else
                   manifest_builder.new(solr_document, *args)
                 end
      raise ManifestBuilder::ManifestBuildError, I18n.t('works.show.no_image') if JSON.parse(manifest.to_json).blank?
      manifest
    end

    private

      def manifest_builder
        ManifestBuilder
      end

      def sammelband_manifest_builder
        SammelbandManifestBuilder
      end
  end
end

# frozen_string_literal: true
class PolymorphicManifestBuilder
  class << self
    ##
    # Constructor for ManifestBuilders of all Works
    # @param [SolrDocument] solr_document the Document for the Work
    # @param args additional arguments passed to the manifest builder
    def new(solr_document, *args)
      begin
        manifest = if solr_document.member_presenters.map(&:class).uniq.length > 1
                     sammelband_manifest_builder.new(solr_document, *args)
                   elsif solr_document.is_a? CollectionShowPresenter
                     collection_manifest_builder.new(solr_document, *args)
                   elsif solr_document.is_a? MapSetShowPresenter
                     sammelband_manifest_builder.new(solr_document, *args)
                   else
                     manifest_builder.new(solr_document, *args)
                   end
      rescue
        raise ManifestBuilder::ManifestBuildError, I18n.t('works.show.no_image')
      end

      if JSON.parse(manifest.to_json).blank?
        raise ManifestBuilder::ManifestEmptyError, I18n.t('works.show.no_image')
      end
      manifest
    end

    private

      def manifest_builder
        ManifestBuilder
      end

      def sammelband_manifest_builder
        SammelbandManifestBuilder
      end

      def collection_manifest_builder
        SparseMemberCollectionManifest
      end
  end
end

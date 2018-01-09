# frozen_string_literal: true
class AllCollectionsManifestBuilder < ManifestBuilder
  attr_reader :ability
  def initialize(record = nil, ability: nil, ssl: false)
    @ability = ability
    super(record, ssl: ssl)
  end

  private

    def root_path
      "#{helper.root_url(protocol: protocol)}collections/manifest"
    end

    def protocol
      if @ssl
        :https
      else
        :http
      end
    end

    def child_manifest_factory
      SparseMemberCollectionManifest
    end

    def record_property_builder
      ManifestBuilder::CollectionRecordPropertyBuilder.new(record, root_path)
    end

    def manifest_builder_class
      IIIF::Presentation::Collection.new
    end

    def sequence_builder
      nil
    end

    def helper
      @helper ||= ManifestBuilder::ManifestHelper.new
    end

    def record
      @record ||= AllCollectionsPresenter.new(ability)
    end
end

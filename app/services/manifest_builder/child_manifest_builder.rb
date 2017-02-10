class ManifestBuilder
  class ChildManifestBuilder < ManifestBuilder
    def builders
      @builders ||= record_property_builder
    end

    def manifest_builder_class
      if [nil, 'individuals', 'paged', 'continuous'].include?(record.viewing_hint)
        IIIF::Presentation::Manifest.new
      else
        IIIF::Presentation::Collection.new
      end
    end
  end
end

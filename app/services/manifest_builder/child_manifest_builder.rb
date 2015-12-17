class ManifestBuilder
  class ChildManifestBuilder < ManifestBuilder
    def builders
      @builders ||= record_property_builder
    end
  end
end

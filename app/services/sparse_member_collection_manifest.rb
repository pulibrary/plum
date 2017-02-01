class SparseMemberCollectionManifest < ManifestBuilder
  def apply(manifest)
    manifest['collections'] ||= []
    manifest['collections'] += [self.manifest]
  end

  def manifest_builders
    nil
  end

  def manifest_builder_class
    IIIF::Presentation::Collection.new
  end

  def sequence_builder
    nil
  end
end

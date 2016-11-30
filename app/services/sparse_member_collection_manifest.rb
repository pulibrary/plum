class SparseMemberCollectionManifest < ManifestBuilder
  def apply(manifest)
    manifest['collections'] ||= []
    manifest['collections'] += [self.manifest]
  end

  def child_manifest_factory
    OnlyPropertyManifestBuilder
  end
end
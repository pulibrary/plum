# frozen_string_literal: true
class ChildCollectionManifest < ManifestBuilder
  def apply(manifest)
    manifest['collections'] ||= []
    manifest['collections'] += [self.manifest]
  end
end

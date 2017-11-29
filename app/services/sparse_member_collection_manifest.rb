# frozen_string_literal: true
class SparseMemberCollectionManifest < ManifestBuilder
  def apply(manifest)
    manifest['collections'] ||= []
    manifest['collections'] += [self.manifest]
  end

  def manifest_builder_class
    IIIF::Presentation::Collection.new
  end

  def sequence_builder
    nil
  end

  def pdf_link_builder
    nil
  end

  def thumbnail_builder
    nil
  end
end

# frozen_string_literal: true
class OnlyPropertyManifestBuilder < ManifestBuilder
  def builders
    @builders ||=
      CompositeBuilder.new(
        record_property_builder
      )
  end

  def manifest_builder_class
    if record.viewing_hint == "multi-part"
      IIIF::Presentation::Collection.new
    else
      IIIF::Presentation::Manifest.new
    end
  end
end

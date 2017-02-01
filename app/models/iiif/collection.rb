module IIIF
  class Collection < Manifest
    def initialize(*args)
      super
      self['@type'] = "sc:Collection"
    end

    def manifests
      self['manifests'] || []
    end

    def manifests=(manifests)
      manifests.map! do |manifest|
        if manifest.kind_of?(::IIIF::Presentation::Manifest)
          JSON.parse(manifest.to_json)
        else
          manifest
        end
      end
      self['manifests'] = manifests
    end
  end
end

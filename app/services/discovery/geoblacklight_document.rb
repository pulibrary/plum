module Discovery
  class GeoblacklightDocument < GeoWorks::Discovery::GeoblacklightDocument
    attr_accessor :iiif

    # Overrides references to add iiif ref
    def references
      {
        'http://schema.org/url' => url,
        'http://www.opengis.net/cat/csw/csdgm' => fgdc,
        'http://www.isotc211.org/schemas/2005/gmd/' => iso19139,
        'http://www.loc.gov/mods/v3' => mods,
        'http://schema.org/downloadUrl' => download,
        'http://schema.org/thumbnailUrl' => thumbnail,
        'http://www.opengis.net/def/serviceType/ogc/wms' => wms_path,
        'http://www.opengis.net/def/serviceType/ogc/wfs' => wfs_path,
        'http://iiif.io/api/image' => iiif
      }
    end
  end
end

module Discovery
  class GeoblacklightDocument < GeoWorks::Discovery::GeoblacklightDocument
    attr_accessor :iiif, :iiif_manifest

    def to_hash(_args = nil)
      return document unless access_rights == private_visibility
      private_document
    end

    # Override to return a different geoblacklight document for works with private visibility
    def to_json(_args = nil)
      return document.to_json unless access_rights == private_visibility
      private_document.to_json
    end

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
        'http://iiif.io/api/image' => iiif,
        'http://iiif.io/api/presentation#manifest' => iiif_manifest
      }
    end

    def rights
      case access_rights
      when public_visibility
        'Public'
      else
        'Restricted'
      end
    end

    # Dct references hash with download, WxS, and IIIF refs removed
    def private_references
      {
        'http://schema.org/url' => url,
        'http://www.opengis.net/cat/csw/csdgm' => fgdc,
        'http://www.isotc211.org/schemas/2005/gmd/' => iso19139,
        'http://schema.org/thumbnailUrl' => thumbnail
      }
    end

    # Insert special dct references for works with private visibility
    def private_document_hash
      optional = document_hash_optional
      optional[:dct_references_s] = clean_document(private_references).to_json.to_s
      document_hash_required.merge(optional)
    end

    def private_document
      clean = clean_document(private_document_hash)
      if valid?(clean)
        clean
      else
        schema_errors(clean)
      end
    end

    def public_visibility
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end

    def private_visibility
      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end
  end
end

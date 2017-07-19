class ManifestBuilder
  class LicenseBuilder
    attr_reader :record
    def initialize(record)
      @record = record
    end

    def apply(manifest)
      return unless record.try(:rights_statement_uri)
      manifest.license = record.rights_statement_uri
      manifest
    end
  end
end

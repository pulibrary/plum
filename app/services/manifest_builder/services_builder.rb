class ManifestBuilder
  class ServicesBuilder
    attr_reader :record

    def initialize(record)
      @record = record
    end

    def apply(manifest)
      return if
        record.class == AllCollectionsPresenter ||
        record.class == CollectionShowPresenter
      service_array = {
        "@context"  => "http://iiif.io/api/search/0/context.json",
        "@id"       => "http://localhost:3000/search/#{record.id}",
        "profile"   => "http://iiif.io/api/search/0/search",
        "label"     => "Search within item."
      }
      manifest["service"] = [service_array]
    end
  end
end

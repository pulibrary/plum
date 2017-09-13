class ManifestBuilder
  class ServicesBuilder
    include Rails.application.routes.url_helpers

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
        "@id"       => "#{root_url}search/#{record.id}",
        "profile"   => "http://iiif.io/api/search/0/search",
        "label"     => "Search within item."
      }
      manifest["service"] = [service_array]
    end
  end
end

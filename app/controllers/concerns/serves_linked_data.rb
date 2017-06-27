module ServesLinkedData
  extend ActiveSupport::Concern

  included do
    def export_as_jsonld
      {}
    end

    def export_as_nt
      RDF::Graph.new.from_jsonld(export_as_jsonld).dump(:ntriples)
    end

    def export_as_ttl
      RDF::Graph.new.from_jsonld(export_as_jsonld).dump(:ttl)
    end
  end
end

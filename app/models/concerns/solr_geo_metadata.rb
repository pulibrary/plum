module SolrGeoMetadata
  extend ActiveSupport::Concern
  included do
    def alternative
      Array(self[Solrizer.solr_name("alternative")])
    end

    def edition
      Array(self[Solrizer.solr_name("edition")])
    end

    def cartographic_scale
      Array(self[Solrizer.solr_name("cartographic_scale")]).first
    end

    def cartographic_projection
      Array(self[Solrizer.solr_name("cartographic_projection")]).first
    end
  end
end

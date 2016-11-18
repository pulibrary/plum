module SolrTechnicalMetadata
  extend ActiveSupport::Concern
  included do
    def color_space
      self[Solrizer.solr_name('color_space', :symbol)]
    end

    def digest
      self[Solrizer.solr_name('digest', :symbol)]
    end

    def file_size
      self[Solrizer.solr_name('file_size', Solrizer::Descriptor.new(:integer, :stored))]
    end

    def height
      self[Solrizer.solr_name('height', Solrizer::Descriptor.new(:integer, :stored))]
    end

    def profile_name
      self[Solrizer.solr_name('profile_name', :symbol)]
    end

    def valid
      self[Solrizer.solr_name('valid', :symbol)]
    end

    def well_formed
      self[Solrizer.solr_name('well_formed', :symbol)]
    end

    def width
      self[Solrizer.solr_name('width', Solrizer::Descriptor.new(:integer, :stored))]
    end
  end
end

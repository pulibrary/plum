class WorkIndexer < CurationConcerns::WorkIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      object.member_of_collections.each do |col|
        solr_doc[Solrizer.solr_name('member_of_collection_slugs', :symbol)] = col.exhibit_id
      end
    end
  end
end

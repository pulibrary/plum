class CollectionIndexer < CurationConcerns::CollectionIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      titles = solr_doc[Solrizer.solr_name('title', :stored_searchable)] || []
      solr_doc['title_ssort'] = titles.to_sentence
    end
  end
end

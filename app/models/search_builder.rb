class SearchBuilder < CurationConcerns::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  def hide_parented_resources(solr_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "!#{ActiveFedora::SolrQueryBuilder.solr_name('ordered_by', :symbol)}:['' TO *]"
  end
end

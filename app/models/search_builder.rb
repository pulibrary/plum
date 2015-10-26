class SearchBuilder < CurationConcerns::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  def hide_parented_resources(solr_params)
    return if show_action?
    solr_params[:fq] ||= []
    solr_params[:fq] << "!#{ActiveFedora::SolrQueryBuilder.solr_name('ordered_by', :symbol)}:['' TO *]"
  end

  def join_from_parent(solr_params)
    return if show_action?
    solr_params[:q] = "({!join from=ordered_by_ssim to=id}{!dismax}#{solr_params[:q]}) OR ({!dismax}#{solr_params[:q]})"
  end

  def show_action?
    blacklight_params["action"] == "show"
  end
end

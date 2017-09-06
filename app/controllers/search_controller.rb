class SearchController < ApplicationController
  def index
    render 'search/search.html.erb'
  end

  def search
    search_term = params[:q]
    @parent_id = params[:id]
    @parent_path = find_parent_path(@parent_id)
    # solr query for has_model_ssim
    # convert camel case to snake case
    @response = ActiveFedora::SolrService.query("full_text_tesim:#{search_term}", fq: "ordered_by_ssim:#{params[:id]}")
    @docs = @response.map do |doc|
      doc_text = doc['full_text_tesim'][0]
      doc[:hit_number] = doc_text.scan(/\w+/).count(search_term)
      doc[:word] = search_term
      doc
    end

    @pages_json = {}
    @docs.map do |doc|
      json_file = PairtreeDerivativePath.derivative_path_for_reference(doc['id'], "json")
      next unless File.exist?(json_file)
      json = File.read json_file
      page_json = JSON.parse(json)
      @pages_json[doc['id']] = page_json
    end

    # We keep track of how many times a particular word has had a hit so that we
    # pick the correct @pages_json word boundary. This compensates for how there
    # could be more than one hit in a snippet.
    @hits_used = {}

    request.format = :json
    respond_to :json
  end

  private

    def find_parent_path(id)
      response = ActiveFedora::SolrService.query("id:#{id}")
      "#{request.base_url}/concern/#{response[0]['has_model_ssim'][0].to_s.underscore}s/#{id}"
    end
end

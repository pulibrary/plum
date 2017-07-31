class SearchController < ApplicationController
  def index
    render 'search/search.html.erb'
  end

  def search
    # solr = RSolr.connect url: Rails.configuration.ocracoke['solr_url']

    search_term = params[:q]

    solr = RSolr.connect url: "http://localhost:8983/solr/hydra-development"
    # solr_params = {
    #   fq: "id:#{params[:id]}",
    #   q: "full_text_tesim:#{params[:q]}"
    # }
    solr_params = {
      q: "full_text_tesim:#{search_term}",
      fq: "ordered_by_ssim:#{params[:id]}"
    }

    @response = solr.get 'select', params: solr_params

    @docs = @response["response"]["docs"].map do |doc|
      doc_text = doc['full_text_tesim'][0]
      doc[:hit_number] = doc_text.scan(/\w+/).count(search_term)
      doc[:word] = search_term
      doc
    end

    @pages_json = {}
    # first_two_chars = params[:id][0, 2]
    @docs.map do |doc|
      json_file = PairtreeDerivativePath.derivative_path_for_reference(doc['id'], "json")
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
end

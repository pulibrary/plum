class SearchController < ApplicationController
  def index
    render 'search/search.html.erb'
  end

  def search
    search_term = params[:q]
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
end

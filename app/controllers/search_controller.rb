class SearchController < ApplicationController

  def index
    render 'search/search.html.erb'
  end

  def search
    respond_to :json
  end
end

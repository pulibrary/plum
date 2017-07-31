require 'rails_helper'

RSpec.describe "Search Routing" do
  it "routes to the default action" do
    expect(get default_search_path).to route_to controller: "search", action: "index"
  end

  it "routes to search action" do
    expect(get search_path(id: "123")).to route_to controller: "search", action: "search", id: "123"
  end
end

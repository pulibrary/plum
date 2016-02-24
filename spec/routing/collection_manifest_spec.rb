require 'rails_helper'

RSpec.describe "Collection Manifest Routes" do
  it "responds to the right helper" do
    expect(manifest_collection_path(id: "1")).to eq "/collections/1/manifest"
  end
  it "routes to the manifest action" do
    expect(get manifest_collection_path(id: "1")).to route_to controller: "collections", action: "manifest", format: :json, id: "1"
  end

  it "can route an index manifest" do
    expect(get "/iiif/collections").to route_to controller: "collections", action: "index_manifest", format: :json
  end
end

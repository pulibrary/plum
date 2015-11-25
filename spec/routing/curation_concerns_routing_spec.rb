require 'rails_helper'

RSpec.describe "Curation Concerns Routing" do
  describe "#reorder_curation_concerns_scanned_resource" do
    it "routes right" do
      expect(get '/concern/scanned_resources/1/reorder').to route_to controller: "curation_concerns/scanned_resources", action: "reorder", id: '1'
      expect(reorder_curation_concerns_scanned_resource_path(id: '1')).to eq "/concern/scanned_resources/1/reorder"
    end
    it "can be POSTed to" do
      expect(post reorder_curation_concerns_scanned_resource_path(id: '1')).to route_to controller: "curation_concerns/scanned_resources", action: "save_order", id: '1'
    end
  end

  describe "#browse_everything_files_curation_concerns_scanned_resource_path" do
    it "routes" do
      expect(post browse_everything_files_curation_concerns_scanned_resource_path(id: 1)).to route_to controller: "curation_concerns/scanned_resources", action: "browse_everything_files", id: '1'
    end
  end
end

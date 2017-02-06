require 'rails_helper'

RSpec.describe "Curation Concerns Routing" do
  describe "#browse_everything_files_curation_concerns_scanned_resource_path" do
    it "routes" do
      expect(post browse_everything_files_curation_concerns_scanned_resource_path(id: 1)).to route_to controller: "curation_concerns/scanned_resources", action: "browse_everything_files", id: '1'
    end
  end
end

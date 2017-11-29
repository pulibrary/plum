# frozen_string_literal: true
require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the EphemeraFieldsHelper. For example:
#
# describe EphemeraFieldsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe EphemeraFieldsHelper, type: :helper do
  let(:fields) { [
    "EphemeraFolder.genre",
    "EphemeraFolder.language",
    "EphemeraFolder.geographic_origin",
    "EphemeraFolder.geo_subject",
    "EphemeraFolder.subject"
  ] }

  describe "#controllable_fields" do
    it "lists the controllable fields" do
      expect(helper.controllable_fields).to match_array(fields)
    end
  end
end

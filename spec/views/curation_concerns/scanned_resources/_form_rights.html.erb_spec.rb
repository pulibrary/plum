require 'rails_helper'

describe "curation_concerns/scanned_resources/_form_rights.html.erb" do
  let(:curation_concern) { ScannedResource.new }
  before do
    form = simple_form_for([:curation_concerns, curation_concern])
    render partial: "curation_concerns/scanned_resources/form_rights", locals: {
      f: form
    }
  end
  describe "the usage statement" do
    it "does not have a label" do
      expect(rendered).not_to have_xpath "//label"
    end
    it "defaults to the first statement" do
      expected_value = RightsService.select_options[0][0]
      expect(rendered).to have_xpath("//select/@value", text: expected_value)
    end
  end
end

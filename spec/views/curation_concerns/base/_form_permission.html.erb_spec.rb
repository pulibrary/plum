require 'rails_helper'

RSpec.describe "curation_concerns/base/_form_permission.html.erb" do
  let(:curation_concern) { ScannedResource.new }
  before do
    form = simple_form_for([:curation_concerns, curation_concern])
    render partial: "curation_concerns/base/form_permission", locals: { f: form }
  end

  it "hides embargo" do
    expect(rendered).not_to have_selector "#scanned_resource_embargo_expiration_date"
    expect(rendered).not_to have_selector "#scanned_resource_visibility_after_embargo"
    expect(rendered).not_to have_selector "#scanned_resource_visibility_during_embargo"
  end

  it "hides lease" do
    expect(rendered).not_to have_selector "#scanned_resource_lease_expiration_date"
    expect(rendered).not_to have_selector "#scanned_resource_visibility_after_lease"
    expect(rendered).not_to have_selector "#scanned_resource_visibility_during_lease"
  end
end

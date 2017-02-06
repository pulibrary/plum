require 'rails_helper'

RSpec.describe "hyrax/base/_form_files_and_links.html.erb" do
  let(:curation_concern) { ScannedResource.new }
  before do
    form = simple_form_for([curation_concern])
    render partial: "hyrax/base/form_files_and_links", locals: { f: form }
  end

  it "hides add files section" do
    expect(rendered).not_to have_content "Add Your Content"
  end
end

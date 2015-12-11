require 'rails_helper'

RSpec.describe "curation_concerns/scanned_resources/_show_actions.html.erb" do
  let(:resource) do
    r = FactoryGirl.build(:scanned_resource)
    allow(r).to receive(:id).and_return("test")
    r
  end
  let(:solr_document) { SolrDocument.new(resource.to_solr) }
  let(:presenter) { ScannedResourceShowPresenter.new(solr_document, nil) }
  let(:editor) { true }
  let(:collector) { true }
  before do
    assign(:presenter, presenter)
    render partial: "curation_concerns/scanned_resources/show_actions", locals: { collector: collector, editor: editor }
  end
  it "renders a reorder link" do
    expect(rendered).to have_link "Bulk Edit", bulk_edit_curation_concerns_scanned_resource_path(id: resource.id)
  end
  it "renders an Edit Structure link" do
    expect(rendered).to have_link "Edit Structure", structure_curation_concerns_scanned_resource_path(id: resource.id)
  end
  it "renders a server upload form" do
    expect(rendered).to have_selector "form#browse-everything-form"
    expect(rendered).to have_selector "button.browse-everything"
  end
  context "when there are pending uploads" do
    let(:presenter) do
      s = ScannedResourceShowPresenter.new(solr_document, nil)
      allow(s).to receive(:pending_uploads).and_return([pending_upload])
      s
    end
    let(:pending_upload) { FactoryGirl.build(:pending_upload) }
    it "displays them" do
      expect(rendered).to have_content pending_upload.file_name
    end
  end
end

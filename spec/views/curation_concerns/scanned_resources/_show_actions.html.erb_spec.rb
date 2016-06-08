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
  let(:parent_presenter) {}
  before do
    assign(:presenter, presenter)
    assign(:parent_presenter, parent_presenter)
    render partial: "curation_concerns/scanned_resources/show_actions", locals: { collector: collector, editor: editor }
  end
  it "renders a reorder link" do
    expect(rendered).to have_link I18n.t('file_manager.link_text'), href: file_manager_curation_concerns_scanned_resource_path(id: resource.id)
  end
  it "renders an Edit Structure link" do
    expect(rendered).to have_link "Edit Structure", href: structure_curation_concerns_scanned_resource_path(id: resource.id)
  end
  context "when there's a parent presenter" do
    let(:parent_presenter) { presenter }
    it "renders a link to the contextual file manager" do
      expect(rendered).to have_link "File Manager", href: file_manager_curation_concerns_parent_scanned_resource_path(id: resource.id, parent_id: parent_presenter.id)
    end
  end
end

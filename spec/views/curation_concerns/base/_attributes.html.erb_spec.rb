require 'rails_helper'

RSpec.describe "curation_concerns/base/_attributes.html.erb" do
  let(:creator) { 'Bilbo' }
  let(:date_created) { "2015-09-08" }
  let(:rights_statement) { "http://rightsstatements.org/vocab/NKC/1.0/" }
  let(:workflow_note) { ["First", "Second"] }

  let(:solr_document) do
    SolrDocument.new(
      active_fedora_model_ssi: 'ScannedResource',
      creator_tesim: creator,
      date_created_tesim: date_created,
      rights_statement_tesim: rights_statement,
      workflow_note_tesim: workflow_note
    )
  end
  let(:presenter) do
    ScannedResourceShowPresenter.new(solr_document, nil)
  end
  let(:can_edit) { false }

  before do
    allow(view).to receive(:dom_class) { '' }
    allow(presenter).to receive(:in_collections).and_return([])

    assign(:presenter, presenter)
    allow(view).to receive(:can?).with(:edit, presenter.id).and_return(can_edit)
    render
  end

  it "displays creator" do
    assert_catalog_link('creator', creator)
  end

  it "displays the label for the rights URI" do
    expect(rendered).to have_content "No Known Copyright"
  end

  it "displays date created" do
    expect(rendered).to have_content date_created
  end

  context "when they can edit" do
    let(:can_edit) { true }
    it "displays workflow note" do
      expect(rendered).to have_content "Workflow note"
      expect(rendered).to have_content "First"
    end
  end

  context "when they can't edit" do
    let(:can_edit) { false }
    it "doesn't display workflow note" do
      expect(rendered).not_to have_content "Workflow note"
      expect(rendered).not_to have_content "First"
    end
  end

  def assert_catalog_link(field, value)
    expect(rendered).to have_link(value, href: catalog_index_path(search_field: field, q: value))
  end
end

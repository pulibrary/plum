require 'rails_helper'

RSpec.describe "curation_concerns/base/_attributes.html.erb" do
  let(:creator) { 'Bilbo' }
  let(:date_created) { "2015-09-08" }
  let(:rights) { "No touching" }

  let(:solr_document) do
    SolrDocument.new(
      creator_tesim: creator,
      date_created_tesim: date_created,
      rights_tesim: rights
    )
  end
  let(:presenter) do
    ScannedResourceShowPresenter.new(solr_document, nil)
  end

  before do
    allow(view).to receive(:dom_class) { '' }

    assign(:presenter, presenter)
    render
  end

  it "displays creator" do
    assert_catalog_link('creator', creator)
  end

  it "displays rights" do
    expect(rendered).to have_content rights
  end

  it "displays date created" do
    expect(rendered).to have_content date_created
  end

  def assert_catalog_link(field, value)
    expect(rendered).to have_link(value, href: catalog_index_path(search_field: field, q: value))
  end
end

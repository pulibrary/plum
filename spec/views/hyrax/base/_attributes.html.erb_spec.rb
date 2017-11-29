# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "hyrax/base/_attributes.html.erb" do
  let(:creator) { 'Bilbo' }
  let(:date) { "2015" }
  let(:rights_statement) { "http://rightsstatements.org/vocab/NKC/1.0/" }

  let(:solr_document) do
    SolrDocument.new(
      id: 'test',
      has_model_ssim: ['ScannedResource'],
      creator_tesim: creator,
      author_tesim: 'Baggins',
      source_metadata_identifier_tesim: '8675309',
      date_tesim: date,
      language_tesim: 'ara',
      rights_statement_tesim: rights_statement
    )
  end
  let(:presenter) do
    ScannedResourceShowPresenter.new(solr_document, nil)
  end
  let(:can_edit) { false }

  before do
    allow(view).to receive(:dom_class) { '' }
    allow(presenter).to receive(:member_of_collections).and_return([])

    assign(:presenter, presenter)
    allow(view).to receive(:can?).with(:edit, presenter.id).and_return(can_edit)
    render
  end

  it "displays creator" do
    assert_catalog_link('creator', creator)
  end

  it "displays metadata in plum schema" do
    expect(rendered).to have_content 'Baggins'
  end

  it "displays the metadata source id" do
    expect(rendered).to have_content '8675309'
  end

  it "displays the label for the rights URI" do
    expect(rendered).to have_content "No Known Copyright"
  end

  it "displays date" do
    expect(rendered).to have_content "2015"
  end

  it "displays language name" do
    expect(rendered).to have_content 'Arabic'
  end

  def assert_catalog_link(field, value)
    expect(rendered).to have_link(value, href: search_catalog_path(search_field: field, q: value))
  end
end

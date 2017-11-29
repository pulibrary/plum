# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "hyrax/vector_works/show.html.erb" do
  let(:resource) do
    FactoryGirl.build(:vector_work, id: 'test',
                                    title: ['a vector work'],
                                    creator: ['Dangermond'],
                                    date_created: ['1969-12-31'],
                                    rights: ['In Copyright'])
  end
  let(:solr_document) { SolrDocument.new(resource.to_solr) }
  let(:ability) do
    a = double("ability")
    allow(a).to receive(:can?).and_return(true)
    a
  end
  let(:presenter) { VectorWorkShowPresenter.new(solr_document, ability) }
  let(:blacklight_config) { CatalogController.new.blacklight_config }
  let(:editor) { true }
  let(:collector) { true }
  before do
    stub_blacklight_views
    assign(:presenter, presenter)
    allow(view).to receive(:provide).with(:page_title, 'a vector work')
    allow(view).to receive(:provide).with(:page_header).and_yield
    render template: "hyrax/vector_works/show", locals: { collector: collector, editor: editor }
  end
  it "renders the human readable Work type as Vector Work" do
    expect(rendered).to have_selector 'span.human_readable_type', text: '(Vector Work)'
  end
end

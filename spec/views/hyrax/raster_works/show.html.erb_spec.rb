# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "hyrax/raster_works/show.html.erb" do
  let(:resource) do
    FactoryGirl.build(:raster_work, id: 'test',
                                    title: ['a raster work'],
                                    creator: ['Gerardus'],
                                    date_created: ['1595-01-02'],
                                    rights: ['No Warping'])
  end
  let(:solr_document) { SolrDocument.new(resource.to_solr) }
  let(:ability) do
    a = double("ability")
    allow(a).to receive(:can?).and_return(true)
    a
  end
  let(:presenter) { RasterWorkShowPresenter.new(solr_document, ability) }
  let(:blacklight_config) { CatalogController.new.blacklight_config }
  let(:editor) { true }
  let(:collector) { true }
  before do
    stub_blacklight_views
    assign(:presenter, presenter)
    allow(view).to receive(:provide).with(:page_title, 'a raster work')
    allow(view).to receive(:provide).with(:page_header).and_yield
    render template: "hyrax/raster_works/show", locals: { collector: collector, editor: editor }
  end
  it "renders the human readable Work type as Vector Work" do
    expect(rendered).to have_selector 'span.human_readable_type', text: '(Raster Work)'
  end
end

require 'rails_helper'

RSpec.describe "hyrax/raster_works/_show_actions.html.erb" do
  let(:resource) do
    r = FactoryGirl.build(:raster_work)
    allow(r).to receive(:id).and_return("test")
    r
  end
  let(:solr_document) { SolrDocument.new(resource.to_solr) }
  let(:presenter) { RasterWorkShowPresenter.new(solr_document, nil) }
  let(:editor) { true }
  let(:collector) { true }
  let(:parent_presenter) {}
  before do
    assign(:presenter, presenter)
    assign(:parent_presenter, parent_presenter)
    render partial: "hyrax/raster_works/show_actions", locals: { collector: collector, editor: editor }
  end
  it "renders an Attach Raster link" do
    expect(rendered).to have_link 'Attach Raster', href: main_app.new_hyrax_file_set_path(presenter, type: 'raster-data')
  end
end

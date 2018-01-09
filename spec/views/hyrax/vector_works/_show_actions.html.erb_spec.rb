# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "hyrax/vector_works/_show_actions.html.erb" do
  let(:resource) do
    r = FactoryGirl.build(:vector_work)
    allow(r).to receive(:id).and_return("test")
    r
  end
  let(:solr_document) { SolrDocument.new(resource.to_solr) }
  let(:presenter) { VectorWorkShowPresenter.new(solr_document, nil) }
  let(:editor) { true }
  let(:collector) { true }
  let(:parent_presenter) {}
  before do
    assign(:presenter, presenter)
    assign(:parent_presenter, parent_presenter)
    render partial: "hyrax/vector_works/show_actions", locals: { collector: collector, editor: editor }
  end
  it "renders an Attach Vector link" do
    expect(rendered).to have_link 'Attach Vector', href: main_app.new_hyrax_file_set_path(presenter, type: 'vector-data')
  end
end

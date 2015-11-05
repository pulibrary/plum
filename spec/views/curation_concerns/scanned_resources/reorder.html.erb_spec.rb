require 'rails_helper'

RSpec.describe "curation_concerns/scanned_resources/reorder.html.erb" do
  let(:presenter) { ScannedResourceShowPresenter.new(SolrDocument.new(resource.to_solr), nil) }
  let(:resource) do
    g = FactoryGirl.build(:scanned_resource)
    allow(g).to receive(:id).and_return("resource")
    g
  end
  let(:members) { file_sets.map { |x| FileSetPresenter.new(SolrDocument.new(x.to_solr), nil) } }
  let(:file_sets) { [file_set1] }
  let(:file_set1) do
    g = FactoryGirl.build(:file_set)
    allow(g).to receive(:id).and_return("file_set")
    g
  end
  let(:blacklight_config) { CatalogController.new.blacklight_config }
  before do
    assign :presenter, presenter
    assign :members, members
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:search_session).and_return({})
    allow(view).to receive(:current_search_session).and_return(nil)
    render
  end
  it "renders a form for each member" do
    expect(rendered).to have_selector("form", count: members.length)
  end
  it "renders an input for titles" do
    expect(rendered).to have_selector("input[name='file_set[title][]']")
  end
  it "has radio inputs for viewing hints" do
    expect(rendered).to have_selector("input[type=radio][name='file_set[viewing_hint]']", count: 3)
    ["Single Page", "Non-Paged", "Facing pages"].each do |hint|
      expect(rendered).to have_field hint
    end
  end
end

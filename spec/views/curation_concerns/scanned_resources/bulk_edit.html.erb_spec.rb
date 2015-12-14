require 'rails_helper'

RSpec.describe "curation_concerns/scanned_resources/bulk_edit.html.erb" do
  let(:members) { [file_set] }
  let(:file_set) { FileSetPresenter.new(solr_doc, nil) }
  let(:solr_doc) do
    SolrDocument.new(
      resource.to_solr.merge(
        id: "test",
        title_tesim: "Test",
        thumbnail_path_ss: "/test/image/path.jpg",
        label_tesim: "file_name.tif"
      )
    )
  end
  let(:scanned_resource) { FactoryGirl.build(:scanned_resource) }
  let(:resource) { FactoryGirl.build(:file_set) }
  let(:parent) { FactoryGirl.build(:scanned_resource) }
  let(:parent_presenter) do
    ScannedResourceShowPresenter.new(
      SolrDocument.new(
        parent.to_solr.merge(id: "resource")
      ), nil
    )
  end
  let(:blacklight_config) { CatalogController.new.blacklight_config }

  before do
    assign(:members, members)
    assign(:presenter, parent_presenter)
    # Blacklight nonsense
    allow(view).to receive(:dom_class) { '' }
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:search_session).and_return({})
    allow(view).to receive(:current_search_session).and_return(nil)
    allow(view).to receive(:curation_concern).and_return(scanned_resource)
    render
  end

  it "has a bulk edit header" do
    expect(rendered).to include "<h1>Bulk Edit</h1>"
  end

  it "displays each file set's label" do
    expect(rendered).to have_selector "input[name='file_set[title][]'][type='text'][value='#{file_set}']"
  end

  it "displays each file set's file name" do
    expect(rendered).to have_content "file_name.tif"
  end

  it "has a link back to parent" do
    expect(rendered).to have_link "Back to Parent", href: curation_concerns_scanned_resource_path(id: "resource")
  end

  it "has an actions bar for labeling" do
    expect(rendered).to have_selector("input[name=start_with]")
    expect(rendered).to have_selector("input[name=method]")
    expect(rendered).to have_selector("input[name=unit_label]")
    expect(rendered).to have_selector("input[name=bracket]")
    expect(rendered).to have_selector("input[name=front_label]")
    expect(rendered).to have_selector("input[name=back_label]")
    expect(rendered).to have_selector("input[name=foliate_start_with]")
    expect(response).to have_selector("*[data-action=bulk-label]")
  end

  it "has thumbnails for each resource" do
    expect(rendered).to have_selector("img[src='/test/image/path.jpg']")
  end

  it "renders a form for each member" do
    expect(rendered).to have_selector("form", count: members.length + 1)
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

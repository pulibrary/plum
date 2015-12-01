require 'rails_helper'

RSpec.describe "curation_concerns/scanned_resources/bulk_label.html.erb" do
  let(:members) { [file_set] }
  let(:file_set) { FileSetPresenter.new(solr_doc, nil) }
  let(:solr_doc) do
    SolrDocument.new(
      resource.to_solr.merge(
        id: "test"
      )
    )
  end
  let(:resource) { FactoryGirl.build(:file_set) }
  let(:parent) { FactoryGirl.build(:scanned_resource) }
  let(:parent_presenter) do
    ScannedResourceShowPresenter.new(
      SolrDocument.new(
        parent.to_solr.merge(id: "resource")
      ), nil
    )
  end

  before do
    assign(:members, members)
    assign(:presenter, parent_presenter)
    render
  end

  it "has a bulk label header" do
    expect(rendered).to include "<h1>Bulk Label</h1>"
  end

  it "displays each file set's label" do
    expect(rendered).to have_text file_set.to_s
    expect(rendered).to have_selector "input[name='file_set[title][]'][type='hidden']"
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
end

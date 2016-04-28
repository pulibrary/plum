require 'rails_helper'

RSpec.describe "curation_concerns/base/file_manager.html.erb" do
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
  let(:resource) { FactoryGirl.build(:file_set) }

  let(:parent) { FactoryGirl.build(:scanned_resource) }
  let(:parent_solr_doc) do
    SolrDocument.new(parent.to_solr.merge(id: "resource"), nil)
  end
  let(:pending_upload) { FactoryGirl.build(:pending_upload) }
  let(:parent_presenter) do
    s = ScannedResourceShowPresenter.new(parent_solr_doc, nil)
    allow(s).to receive(:pending_uploads).and_return([pending_upload])
    s
  end

  let(:blacklight_config) { CatalogController.new.blacklight_config }
  let(:context) { Blacklight::Configuration::Context.new double }

  before do
    assign(:presenter, parent_presenter)
    allow(parent_presenter).to receive(:file_presenters).and_return(members)
    stub_blacklight_views
    allow(view).to receive(:curation_concern).and_return(parent)
    render
  end

  context "for a MVW" do
    let(:parent) { FactoryGirl.build(:multi_volume_work) }
    let(:parent_presenter) do
      s = MultiVolumeWorkShowPresenter.new(parent_solr_doc, nil)
      allow(s).to receive(:pending_uploads).and_return([pending_upload])
      s
    end
    let(:file_set) { ScannedResourceShowPresenter.new(solr_doc, nil) }
    let(:resource) { FactoryGirl.build(:scanned_resource) }
    it "renders scanned resources as reorderable" do
      expect(rendered).to have_selector "input[name='scanned_resource[title][]'][type='text'][value='#{file_set}']"
    end
    it "has a link back to parent" do
      expect(rendered).to have_link "Test title", href: curation_concerns_multi_volume_work_path(id: "resource")
    end
    it "doesn't have radio inputs" do
      expect(rendered).not_to have_selector("#sortable input[type=radio][name='scanned_resource[viewing_hint]']")
    end
  end

  it "displays helper text" do
    expect(rendered).to include "Select files or directories to upload, or drag them here."
  end

  it "has a file manager header" do
    expect(rendered).to include "<h1>#{I18n.t('file_manager.link_text')}</h1>"
  end

  it "displays each file set's label" do
    expect(rendered).to have_selector "input[name='file_set[title][]'][type='text'][value='#{file_set}']"
  end

  it "displays each file set's file name" do
    expect(rendered).to have_content "file_name.tif"
  end

  it "has a link to edit each file set" do
    expect(rendered).to have_selector('a[href="/concern/file_sets/test"]')
  end

  it "has a link back to parent" do
    expect(rendered).to have_link "Test title", href: curation_concerns_scanned_resource_path(id: "resource")
  end

  it "has an actions bar for labeling" do
    expect(rendered).to have_selector("input[name=start_with]")
    expect(rendered).to have_selector("input[name=method]")
    expect(rendered).to have_selector("input[name=unit_label]")
    expect(rendered).to have_selector("input[name=bracket]")
    expect(rendered).to have_selector("input[name=front_label]")
    expect(rendered).to have_selector("input[name=back_label]")
    expect(rendered).to have_selector("input[name=foliate_start_with]")
    expect(response).to have_selector("*[data-action=file-manager]")
  end

  it "has thumbnails for each resource" do
    expect(rendered).to have_selector("img[src='#{IIIFPath.new(file_set.id)}/full/!200,150/0/default.jpg']")
  end

  it "renders a form for each member" do
    expect(rendered).to have_selector("form", count: members.length + 3)
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

  it "renders an OSD link for each member" do
    expect(rendered).to have_selector("*[data-modal-manifest='#{IIIFPath.new(file_set.id)}/info.json']")
  end

  it "renders a server upload form" do
    expect(rendered).to have_selector "form#browse-everything-form"
    expect(rendered).to have_selector "button.browse-everything"
  end

  it "displays pending uploads" do
    expect(rendered).to have_content pending_upload.file_name
  end

  it "has inputs to edit the viewing hint" do
    expect(rendered).to have_selector("input[name='scanned_resource[viewing_hint]']")
  end

  it "has a multi-select input to edit the ocr language" do
    expect(rendered).to have_selector("select[name='scanned_resource[ocr_language][]']")
    expect(rendered).to have_selector("select[name='scanned_resource[ocr_language][]'] > option[value='eng']")
    expect(rendered).to have_text "English"
  end

  context "when it's a MVW" do
    let(:parent) { FactoryGirl.build(:multi_volume_work) }
    it "has a correct input to edit the viewing hint" do
      expect(rendered).to have_selector("input[name='multi_volume_work[viewing_hint]']")
    end
  end
end

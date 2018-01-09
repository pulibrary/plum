# frozen_string_literal: true
require 'rails_helper'

describe "hyrax/multi_volume_works/show.html.erb" do
  let(:creator) { 'Bilbo' }
  let(:date_created) { "2015-09-08" }
  let(:rights) { "No touching" }

  let(:solr_document) do
    SolrDocument.new(
      creator_tesim: creator,
      date_created_tesim: date_created,
      rights_tesim: rights,
      has_model_ssim: ["MultiVolumeWork"],
      id: "2"
    )
  end
  let(:resource_document) do
    SolrDocument.new(
      title_ssim: "test",
      title_tesim: "test",
      thumbnail_path_ss: "/test/bla.jpg",
      has_model_ssim: ["ScannedResource"],
      id: "1"
    )
  end
  let(:presenter) do
    MultiVolumeWorkShowPresenter.new(solr_document, ability)
  end
  let(:resource_presenter) do
    ScannedResourceShowPresenter.new(resource_document, ability)
  end
  let(:ability) do
    a = double("ability")
    allow(a).to receive(:can?).and_return(true)
    a
  end
  let(:member_presenter) do
    f = FactoryGirl.build(:file_set)
    allow(f).to receive(:persisted?).and_return(true)
    allow(f).to receive(:id).and_return("2")
    FileSetPresenter.new(SolrDocument.new(f.to_solr), ability)
  end
  let(:blacklight_config) { CatalogController.new.blacklight_config }

  before do
    allow(presenter).to receive(:member_presenters).and_return([resource_presenter, member_presenter])
    stub_blacklight_views
    allow(presenter).to receive(:member_of_collections).and_return([])
    allow(resource_presenter).to receive(:member_of_collections).and_return([])
    assign(:presenter, presenter)
    allow(view).to receive(:contextual_path).with(anything, anything) do |x, y|
      Hyrax::ContextualPath.new(x, y).show
    end
    view.lookup_context.prefixes << "hyrax/base"
    render
  end

  context "when viewing a multi-volume work" do
    it "does not have forms for attaching files" do
      expect(rendered).not_to have_selector 'h2', text: 'Files'
      expect(rendered).not_to have_selector 'div.fileupload-buttonbar'
      expect(rendered).not_to have_selector 'a.btn', text: 'Attach a File'
    end
    it "has thumbnails for its members" do
      expect(rendered).to have_selector("img[src='#{IIIFPath.new(member_presenter.id)}/full/!200,150/0/default.jpg']")
    end
    it "has a link to each edit page" do
      expect(rendered).to have_link "test", href: "/concern/parent/#{presenter.id}/scanned_resources/#{resource_presenter.id}"
      expect(rendered).to have_link member_presenter.to_s, href: "/concern/file_sets/#{member_presenter.id}"
    end
    it "has a link to edit structure" do
      expect(rendered).to have_link "Edit Structure", href: structure_hyrax_multi_volume_work_path(id: presenter.id)
    end
  end
end

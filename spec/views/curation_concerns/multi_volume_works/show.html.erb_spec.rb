require 'rails_helper'

describe "curation_concerns/multi_volume_works/show.html.erb" do
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
      thumbnail_path_ss: "/test/bla.jpg",
      has_model_ssim: ["ScannedResource"],
      id: "1"
    )
  end
  let(:presenter) do
    MultiVolumeWorkShowPresenter.new(solr_document, nil)
  end
  let(:resource_presenter) do
    ScannedResourceShowPresenter.new(resource_document, nil)
  end
  let(:blacklight_config) { CatalogController.new.blacklight_config }

  before do
    allow(presenter).to receive(:file_presenters).and_return([resource_presenter])
    allow(view).to receive(:dom_class) { '' }
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:search_session).and_return({})
    allow(view).to receive(:current_search_session).and_return(nil)
    allow(view).to receive(:can?).and_return(true)
    assign(:presenter, presenter)
    render
  end

  context "when viewing a multi-volume work" do
    it "does not have forms for attaching files" do
      expect(rendered).not_to have_selector 'h2', text: 'Files'
      expect(rendered).not_to have_selector 'div.fileupload-buttonbar'
      expect(rendered).not_to have_selector 'a.btn', text: 'Attach a File'
    end
    it "has thumbnails for its members" do
      expect(rendered).to have_selector("img[src='/test/bla.jpg']")
    end
  end
end

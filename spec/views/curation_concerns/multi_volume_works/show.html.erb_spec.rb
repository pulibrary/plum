require 'rails_helper'

describe "curation_concerns/multi_volume_works/show.html.erb" do
  let(:creator) { 'Bilbo' }
  let(:date_created) { "2015-09-08" }
  let(:rights) { "No touching" }

  let(:solr_document) do
    SolrDocument.new(
      creator_tesim: creator,
      date_created_tesim: date_created,
      rights_tesim: rights
    )
  end
  let(:presenter) do
    MultiVolumeWorkShowPresenter.new(solr_document, nil)
  end

  before do
    allow(view).to receive(:dom_class) { '' }
    assign(:presenter, presenter)
    render
  end

  context "when viewing a multi-volume work" do
    it "does not have forms for attaching files" do
      expect(rendered).not_to have_selector 'h2', text: 'Files'
      expect(rendered).not_to have_selector 'div.fileupload-buttonbar'
      expect(rendered).not_to have_selector 'a.btn', text: 'Attach a File'
    end
  end
end

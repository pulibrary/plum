require 'rails_helper'

RSpec.describe "curation_concerns/scanned_resources/_representative_media.html.erb" do
  let(:work) { instance_double(ScannedResourceShowPresenter, generic_file_ids: file_ids, id: "1") }
  let(:file_ids) { [] }
  before do
    render partial: "curation_concerns/scanned_resources/representative_media", locals: { work: work }
  end
  context "when there are no generic files" do
    it "shows a filler" do
      expect(response).to have_selector "img[src='/assets/nope.png']"
    end
  end
  context "when there are generic files" do
    let(:file_ids) { [1] }
    it "renders the viewer" do
      expect(response).to have_selector ".viewer[data-manifest]"
    end
  end
end

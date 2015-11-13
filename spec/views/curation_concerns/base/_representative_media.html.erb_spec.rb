require 'rails_helper'

RSpec.describe "curation_concerns/base/_representative_media.html.erb" do
  let(:work) { instance_double(ScannedResourceShowPresenter, file_presenters: file_presenters, id: "1", to_model: ScannedResource) }
  let(:file_presenters) { [] }
  before do
    render partial: "curation_concerns/base/representative_media", locals: { work: work }
  end
  context "when there are no generic files" do
    it "shows a filler" do
      expect(response).to have_selector "img[src='/assets/nope.png']"
    end
  end
  context "when there are generic files" do
    let(:file_presenters) { [1] }
    it "renders the viewer" do
      expect(response).to have_selector ".viewer[data-uri]"
    end
  end
end

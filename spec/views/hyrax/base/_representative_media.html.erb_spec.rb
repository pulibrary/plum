# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "hyrax/base/_representative_media.html.erb" do
  let(:presenter) { instance_double(ScannedResourceShowPresenter, member_presenters: member_presenters, id: "1", persisted?: true, model_name: ScannedResource.model_name) }
  let(:member_presenters) { [] }
  let(:can_manifest) { true }
  before do
    allow(presenter).to receive(:to_model).and_return(presenter)
    allow(view).to receive(:can?).with(:manifest, presenter).and_return(can_manifest)
    assign(:manifest_uri, 'http://localhost')
    render partial: "hyrax/base/representative_media", locals: { presenter: presenter }
  end
  context "when there are no generic files" do
    it "shows a filler" do
      expect(response).to have_selector "img[src='/assets/nope.png']"
    end
  end
  context "when there are generic files" do
    let(:member_presenters) { [1] }
    it "renders the viewer" do
      assign(:manifest, test: 'test')
      render partial: "hyrax/base/representative_media", locals: { presenter: presenter }

      expect(response).to have_selector ".viewer[data-uri]"
    end
    context "and the user doesn't have permission to manifest" do
      let(:can_manifest) { false }
      it "doesn't render the viewer" do
        expect(response).to have_selector "img[src='/assets/nope.png']"
      end
    end

    context "without a valid IIIF Manifest" do
      before do
        assign(:manifest, nil)
      end

      it "does not render the viewer" do
        expect(response).not_to have_selector ".viewer[data-uri]"
      end
    end
  end
end

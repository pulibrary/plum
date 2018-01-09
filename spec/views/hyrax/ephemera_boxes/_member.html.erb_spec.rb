# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "hyrax/ephemera_boxes/_member.html.erb" do
  let(:folder) { FactoryGirl.create(:ephemera_folder) }
  let(:box) { FactoryGirl.create(:ephemera_box) }
  let(:box_presenter) { EphemeraBoxPresenter.new(SolrDocument.new(box.to_solr), nil) }
  let(:folder_presenter) { EphemeraFolderPresenter.new(SolrDocument.new(folder.to_solr), nil) }
  before do
    allow(view).to receive(:contextual_path).with(anything, anything) do |x, y|
      Hyrax::ContextualPath.new(x, y).show
    end
    render partial: "hyrax/ephemera_boxes/member", locals: { member: folder_presenter, box: box_presenter }
  end
  it "renders the barcode" do
    expect(rendered).to have_content(folder_presenter.barcode)
  end
end

require 'rails_helper'

RSpec.describe "curation_concerns/file_sets/show.html.erb" do
  let(:file_set_document) { SolrDocument.new(id: 'p1', has_model_ssim: ['FileSet']) }
  let(:file_set_presenter) { FileSetPresenter.new(file_set_document, nil) }

  before do
    stub_blacklight_views
    render partial: "curation_concerns/file_sets/media_display/image", locals: { file_set: file_set_presenter }
  end

  it 'shows a thumbnail from the image server' do
    expect(rendered).to have_selector("img[src='#{IIIFPath.new('p1')}/full/!200,150/0/default.jpg']")
  end
end

# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "hyrax/file_sets/_technical_metadata.html.erb" do
  let(:solr_doc) do
    SolrDocument.new(id: 'p1', generic_work_ids_ssim: ['book1'],
                     has_model_ssim: ['FileSet'], title_tesim: 'p. 1',
                     label_tesim: 'file1.jpg',
                     valid_ssim: 'true', well_formed_ssim: 'true',
                     date_uploaded_dtsi: '2016-11-18T16:33:15Z',
                     date_modified_dtsi: '2016-11-19T16:34:03Z',
                     file_format_tesim: 'tiff (Tagged Image File Format)',
                     file_size_is: 112_121_530, height_is: 3456, width_is: 1234,
                     color_space_ssim: 'RGB', profile_name_ssim: 'Adobe RGB (1998)',
                     digest_ssim: 'urn:sha1:5a4b46c44f062e2bcb3c57576cc3b2d798ba1f0c',
                     original_checksum_tesim: '531b2b4183f7b7c25c7a2cadd77ffd7a')
  end
  let(:file_set_presenter) { FileSetPresenter.new(solr_doc, nil) }

  before do
    assign(:presenter, file_set_presenter)
    render partial: "hyrax/file_sets/technical_metadata"
  end

  it 'shows technical metadata' do
    expect(rendered).to have_selector 'li.well_formed', text: 'true'
    expect(rendered).to have_selector 'li.valid', text: 'true'
    expect(rendered).to have_selector 'li.date_uploaded', text: '11/18/16'
    expect(rendered).to have_selector 'li.date_modified', text: '11/19/16'
    expect(rendered).to have_selector 'li.file_size', text: '112121530'
    expect(rendered).to have_selector 'li.digest', text: 'urn:sha1:5a4b46c44f062e2bcb3c57576cc3b2d798ba1f0c'
    expect(rendered).to have_selector 'li.original_checksum', text: '531b2b4183f7b7c25c7a2cadd77ffd7a'
    expect(rendered).to have_selector 'li.file_format', text: 'tiff (Tagged Image File Format)'
    expect(rendered).to have_selector 'li.profile_name', text: 'Adobe RGB (1998)'
    expect(rendered).to have_selector 'li.color_space', text: 'RGB'
    expect(rendered).to have_selector 'li.height', text: '3456'
    expect(rendered).to have_selector 'li.width', text: '1234'
  end
end

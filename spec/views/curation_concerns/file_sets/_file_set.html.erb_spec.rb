require 'rails_helper'

RSpec.describe "curation_concerns/base/_related_files.html.erb" do
  let(:user) { FactoryGirl.create(:admin) }
  let(:page_document) do
    SolrDocument.new(id: 'p1', generic_work_ids_ssim: ['book1'],
                     has_model_ssim: ['FileSet'], title_tesim: 'p. 1',
                     label_tesim: 'file1.jpg')
  end
  let(:page_presenter) { FileSetPresenter.new(page_document, nil) }

  before do
    allow(view).to receive(:dom_class) { '' }
    allow(view).to receive(:can?).and_return(true)
    allow(view).to receive(:blacklight_config).and_return(CatalogController.new.blacklight_config)
    allow(view).to receive(:search_session).and_return({})
    allow(view).to receive(:current_search_session).and_return(nil)
    allow_message_expectations_on_nil
    allow_any_instance_of(NilClass).to receive(:can?).and_return(true)

    assign(:file_set, page_presenter)
    render partial: "curation_concerns/file_sets/file_set", locals: { file_set: page_presenter }
  end

  it 'shows filename and title' do
    expect(rendered).to have_selector 'td.filename', 'file1.jpg'
    expect(rendered).to have_selector 'div.pagenumber', 'p. 1'
  end
end

RSpec.shared_examples "page header" do |header_method, page_title|
  # rubocop:disable RSpec/DescribeClass
  describe "page header" do
    let(:solr_document) { SolrDocument.new }
    let(:parent_id) { 'testid' }
    let(:presenter) { double(solr_document: solr_document,
                             id: parent_id,
                             to_model: scanned_resource) }
    let(:scanned_resource) do
      s = FactoryGirl.build(:scanned_resource)
      allow(s).to receive(:persisted?).and_return(true)
      allow(s).to receive(:id).and_return(parent_id)
      s
    end
    before do
      assign(:presenter, presenter)
      allow(presenter).to receive(:title).and_return('Test Resource')
    end

    describe 'page_header' do
      subject { helper.send header_method }

      let(:href) { Rails.application.routes.url_helpers
        .curation_concerns_scanned_resource_path(parent_id) }

      it { is_expected.to have_selector('h1', text: page_title) }
      it { is_expected.to have_text('Back to Test Resource') }
      it { is_expected.to have_link('Test Resource', href: href) }
      it { is_expected.to have_selector('ul.breadcrumb') }
    end
  end
end

require 'rails_helper'

describe MultiVolumeWorkHelper do
  let(:solr_document) { SolrDocument.new }
  let(:presenter) { double(solr_document: solr_document,
                           title: 'multi volume work title',
                           human_readable_type: 'Multi Volume Work') }
  before do
    assign(:presenter, presenter)
  end

  describe '#multi_volume_work_page_header' do
    subject { helper.multi_volume_work_page_header }

    it { is_expected.to have_content('multi volume work title') }
    it { is_expected.to have_content('Multi Volume Work') }
    it { is_expected.to have_selector('ul.breadcrumb') }
  end
end

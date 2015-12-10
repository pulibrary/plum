require 'rails_helper'

describe BulkEditHelper do
  let(:solr_document) { SolrDocument.new }
  let(:parent_id) { 'testid' }
  let(:presenter) { double(solr_document: solr_document,
                           id: parent_id) }
  before do
    assign(:presenter, presenter)
  end

  describe '#bulk_edit_page_header' do
    subject { helper.bulk_edit_page_header }

    let(:href) { Rails.application.routes.url_helpers
      .curation_concerns_scanned_resource_path(parent_id) }

    it { is_expected.to have_link('Back to Parent', href: href) }
    it { is_expected.to have_selector('ul.breadcrumb') }
  end
end

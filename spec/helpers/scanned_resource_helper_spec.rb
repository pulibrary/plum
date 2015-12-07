require 'rails_helper'

describe ScannedResourceHelper do
  let(:current_ability) { nil }
  let(:solr_document) { SolrDocument.new(ordered_by_ssim: ['testid']) }
  let(:results) { [{ id: 'testid', title_tesim: 'multi volume work title' }] }
  let(:presenter) { double(solr_document: solr_document,
                           current_ability: current_ability,
                           title: 'scanned resource title',
                           human_readable_type: 'Scanned Resource') }
  before do
    assign(:presenter, presenter)

    # method stub for solr query in presenter factory
    allow(ActiveFedora::SolrService.instance.conn).to receive(:post)
      .with('select', data: { q: "{!terms f=id}testid", rows: 1000, qt: 'standard' })
      .and_return('response' => { 'docs' => results })
  end

  before(:each) do
    allow(helper).to receive(:params).and_return(parent_id: parent_id)
  end

  describe '#scanned_resource_parent_id' do
    subject { helper.scanned_resource_parent_id }

    context 'without parent_id param in resource ordered_by array' do
      let(:parent_id) { 'bogustestid' }
      it { is_expected.to be_nil }
    end

    context 'with parent_id param in resource ordered_by array' do
      let(:parent_id) { 'testid' }
      it { is_expected.to eq 'testid' }
    end
  end

  describe '#scanned_resource_parent_presenter' do
    subject { helper.scanned_resource_parent_presenter }

    context 'without valid parent id' do
      let(:parent_id) { 'bogustestid' }
      it { is_expected.to be_nil }
    end

    context 'with valid parent id' do
      let(:parent_id) { 'testid' }
      it { is_expected.to be_a_kind_of MultiVolumeWorkShowPresenter }
    end
  end

  describe '#scanned_resource_page_header' do
    subject { helper.scanned_resource_page_header }

    context 'without valid parent id' do
      let(:parent_id) { 'bogustestid' }

      it { is_expected.to have_content('scanned resource title') }
      it { is_expected.to have_content('Scanned Resource') }
      it { is_expected.to have_selector('ul.breadcrumb') }
      it { is_expected.not_to have_link('multi volume work title') }
    end

    context 'with valid parent id' do
      let(:parent_id) { 'testid' }
      let(:href) { Rails.application.routes.url_helpers
        .curation_concerns_multi_volume_work_path(parent_id) }

      it { is_expected.to have_content('scanned resource title') }
      it { is_expected.to have_content('Scanned Resource') }
      it { is_expected.to have_selector('ul.breadcrumb') }
      it { is_expected.to have_link('multi volume work title', href: href) }
    end
  end
end

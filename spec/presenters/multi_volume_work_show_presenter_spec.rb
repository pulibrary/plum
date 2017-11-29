# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MultiVolumeWorkShowPresenter do
  subject { described_class.new(solr_doc, nil) }
  let(:solr_doc) { SolrDocument.new(resource.to_solr) }
  let(:resource) { FactoryGirl.build(:multi_volume_work) }
  describe "#member_presenters" do
    context "when the resource has both scanned resources and filesets" do
      before do
        resource.ordered_members << FactoryGirl.create(:file_set)
        resource.ordered_members << FactoryGirl.create(:scanned_resource)
        resource.save
      end
      it "returns appropriate presenters for both" do
        expect(subject.member_presenters.map(&:class)).to contain_exactly(ScannedResourceShowPresenter, FileSetPresenter)
      end
    end
  end
end

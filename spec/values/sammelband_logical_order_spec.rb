require 'rails_helper'

RSpec.describe SammelbandLogicalOrder do
  subject { described_class.new(source_presenter, source_structure) }

  let(:source_presenter) { MultiVolumeWorkShowPresenter.new(solr_doc, nil) }
  let(:solr_doc) { SolrDocument.new(resource.to_solr) }
  let(:resource) { FactoryGirl.build(:multi_volume_work) }
  let(:source_structure) { {} }
  describe "#to_h" do
    context "when there's scanned resources and canvases" do
      let(:sr_1_presenter) { ScannedResourceShowPresenter.new(SolrDocument.new(sr_1.to_solr), nil) }
      let(:sr_1) { FactoryGirl.build(:scanned_resource, id: "test1") }
      let(:sr_2_presenter) { ScannedResourceShowPresenter.new(SolrDocument.new(sr_2.to_solr), nil) }
      let(:sr_2) { FactoryGirl.build(:scanned_resource, id: "test2") }
      let(:file_1) { build_file_set("a") }
      let(:file_2) { build_file_set("b") }
      let(:file_3) { build_file_set("c") }
      let(:file_1_presenter) { FileSetPresenter.new(file_1, nil) }
      let(:file_2_presenter) { FileSetPresenter.new(file_2, nil) }
      let(:file_3_presenter) { FileSetPresenter.new(file_3, nil) }
      before do
        allow(subject).to receive(:member_presenters).and_return([sr_1_presenter, sr_2_presenter, file_3_presenter])
        allow(sr_1_presenter).to receive(:member_presenters).and_return([file_1_presenter])
        allow(sr_2_presenter).to receive(:member_presenters).and_return([file_2_presenter])
        allow(sr_1_presenter).to receive(:logical_order).and_return({
          "nodes": [
            {
              "label": "Chapter 1",
              "nodes": [
                {
                  "proxy": file_1.id
                }
              ]
            }
          ]
        }.with_indifferent_access)
        allow(sr_2_presenter).to receive(:logical_order).and_return({
          "nodes": [
            {
              "label": "Chapter 1",
              "nodes": [
                {
                  "proxy": file_2.id
                }
              ]
            }
          ]
        }.with_indifferent_access)
      end
      def build_file_set(id)
        FileSet.new.tap do |g|
          allow(g).to receive(:persisted?).and_return(true)
          allow(g).to receive(:id).and_return(id)
          g.title = ["Test"]
        end
      end
      context "and the record has a source structure" do
        let(:source_structure) do
          {
            "nodes": [
              {
                "label": "Covers",
                "nodes": [
                  {
                    "proxy": sr_1_presenter.id
                  },
                  {
                    "proxy": sr_2_presenter.id
                  }
                ]
              },
              {
                "proxy": file_3_presenter.id
              }
            ]
          }.with_indifferent_access
        end
        it "embeds the structures in the right place" do
          expect(subject.to_h).to eq({
            "nodes": [
              {
                "label": "Covers",
                "nodes": [
                  {
                    "label": sr_1_presenter.to_s,
                    "nodes": sr_1_presenter.logical_order["nodes"]
                  },
                  {
                    "label": sr_2_presenter.to_s,
                    "nodes": sr_2_presenter.logical_order["nodes"]
                  }
                ]
              },
              {
                "proxy": file_3_presenter.id
              }
            ]
          }.with_indifferent_access)
        end
      end
      context "and one doesn't have a structure" do
        before do
          allow(sr_2_presenter).to receive(:logical_order).and_return({})
        end
        it "uses their canvas IDs instead" do
          expect(subject.to_h).to eq({
            "nodes": [
              {
                "label": sr_1_presenter.to_s,
                "nodes": sr_1_presenter.logical_order["nodes"]
              },
              {
                "label": sr_2_presenter.to_s,
                "nodes": [
                  {
                    "proxy": file_2.id
                  }
                ]
              }
            ]
          }.with_indifferent_access)
        end
      end
      it "merges in their ranges" do
        expect(subject.to_h).to eq({
          "nodes": [
            {
              "label": sr_1_presenter.to_s,
              "nodes": sr_1_presenter.logical_order["nodes"]
            },
            {
              "label": sr_2_presenter.to_s,
              "nodes": sr_2_presenter.logical_order["nodes"]
            }
          ]
        }.with_indifferent_access)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe LogicalOrderGraph do
  subject { described_class.new(graph, head_subject) }

  let(:graph) { order.to_graph }
  let(:order) { LogicalOrder.new(params) }
  let(:head_subject) { order.rdf_subject }
  let(:params) do
    {
      "nodes" => [
        {
          "label": "Chapter 1",
          "nodes": [
            {
              "label": "Page 1",
              "proxy": "a"
            },
            {
              "label": "Page 1",
              "proxy": "b"
            },
            {
              "label": "Chapter 1b",
              "nodes": [
                {
                  "label": "Page 2",
                  "proxy": "c"
                }
              ]
            }
          ]
        },
        {
          "label": "Chapter 2",
          "nodes": [
            {
              "label": "Page 3",
              "proxy": "d"
            }
          ]
        }
      ]
    }.with_indifferent_access
  end

  describe "#to_h" do
    it "returns a good hash" do
      expect(subject.to_h).to eq params
    end
  end

  describe "#nodes" do
    it "returns an array of nodes" do
      expect(subject.nodes.length).to eq 2
    end
    it "returns labels" do
      expect(subject.nodes.first.label).to eq "Chapter 1"
    end
  end

  describe "#proxy_for_id" do
    let(:params) do
      {
        "nodes": [
          {
            "label": "Page 1",
            "proxy": "a"
          }
        ]
      }
    end
    it "returns it" do
      expect(subject.nodes.first.proxy_for_id).to eq "a"
    end
  end
end

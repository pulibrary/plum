require 'rails_helper'

RSpec.describe LogicalOrder do
  subject { described_class.new(params, label) }
  let(:label) {}
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
    }
  end

  it "can accept a URI" do
    expect { described_class.new(params, RDF::URI("http://test.com/bla")) }.not_to raise_error
  end

  describe "#each_section" do
    it "returns every section in the order" do
      expect(subject.each_section.map(&:label)).to eq [
        "Chapter 1",
        "Chapter 1b",
        "Chapter 2"
      ]
    end
  end

  describe "#nodes" do
    it "returns the two nodes" do
      expect(subject.nodes.length).to eq 2
    end
    it "returns orders with labels" do
      expect(subject.nodes.map(&:label)).to eq ["Chapter 1", "Chapter 2"]
    end
    it "has sub-nodes with titles" do
      expect(subject.nodes.first.nodes.map(&:label)).to eq ["Page 1", "Page 1", "Chapter 1b"]
    end
    it "goes N levels deep" do
      deep_node = subject.nodes.first.nodes.first
      expect(deep_node.label).to eq "Page 1"
      expect(deep_node.nodes).to eq []
      expect(deep_node.proxy_for_id).to eq "a"
    end
  end

  describe "a flat thing with two pages" do
    let(:params) do
      {
        "nodes": [
          {
            "label": "Page 1",
            "proxy": "a"
          },
          {
            "label": "Page 2",
            "proxy": "b"
          }
        ]
      }
    end
    it "has two nodes" do
      expect(subject.nodes.length).to eq 2
    end
  end

  describe "#to_graph" do
    let(:result) { subject.to_graph }
    context "for a single level node" do
      let(:params) do
        {
          "nodes": [
            {
              "proxy": "a"
            }
          ]
        }
      end
      let(:label) { "Test Label" }
      it "returns a tiny ordered graph"do
        expect(result.statements.to_a.length).to eq 3
      end
    end
    context "for sibling nodes" do
      let(:params) do
        {
          "nodes": [
            {
              "label": "Chapter 1",
              "proxy": "a"
            },
            {
              "label": "Chapter 1",
              "proxy": "a"
            }
          ]
        }
      end
      it "builds the right number of statements" do
        expect(result.statements.to_a.length).to eq 8
      end
    end
    context "for two deep nodes" do
      let(:params) do
        {
          "nodes": [
            {
              "label": "Chapter 1",
              "proxy": "a"
            }
          ]
        }
      end
      it "doesn't have two-level deep nodes" do
        expect(subject.nodes.first.nodes).to eq []
      end
      it "returns a connected graph" do
        expect(result.statements.to_a.length).to eq 4
        expect(result.subjects.to_a.length).to eq 2
        expect(result.predicates.to_a).to contain_exactly(
          RDF::Vocab::IANA.first,
          RDF::Vocab::IANA.last,
          RDF::Vocab::RDFS.label,
          RDF::Vocab::ORE.proxyFor
        )
      end
    end
    context "for two siblings, one with deep" do
      let(:params) do
        {
          "nodes": [
            {
              "label": "Chapter 1",
              "nodes": [
                {
                  "label": "Chapter 1a",
                  "proxy": "a"
                }
              ]
            },
            {
              "label": "Chapter 1",
              "proxy": "b"
            }
          ]
        }
      end
      it "returns a correct graph" do
        expect(result.statements.to_a.length).to eq 11
      end
    end
    context "for a big graph" do
      it "builds it" do
        expect(result.statements.to_a.length).to eq 25
      end
    end
  end
end

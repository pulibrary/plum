require 'rails_helper'

RSpec.describe WithProxyForObject do
  subject { described_class.new(logical_order, members) }
  let(:logical_order) do
    instance_double(LogicalOrder, proxy_for_id: "test", label: label)
  end
  let(:label) {}
  let(:members) do
    [
      instance_double(ScannedResource, id: "test", to_s: "Banana")
    ]
  end

  describe "#proxy_for_object" do
    it "returns the matching object" do
      expect(subject.proxy_for_object).to eq members.first
    end
  end

  describe "#label" do
    context "when there's a node label" do
      let(:label) { "plum" }
      it "returns it" do
        expect(subject.label).to eq "plum"
      end
    end
    context "when there is only a label on the resource" do
      it "returns it" do
        expect(subject.label).to eq "Banana"
      end
    end
  end

  describe "#unstructured_objects" do
    let(:logical_order) do
      WithProxyForObject::Factory.new(members).new("nodes": [
        {
          "proxy": "test"
        }
      ])
    end
    let(:members) do
      [
        instance_double(ScannedResource, id: "test", to_s: "Banana"),
        member_2
      ]
    end
    let(:member_2) { instance_double(ScannedResource, id: "t", to_s: "Alfafa") }
    it "returns nodes in members but not in structure" do
      expect(subject.unstructured_objects.nodes.length).to eq 1
      expect(subject.unstructured_objects.nodes.first.proxy_for_object).to eq member_2
    end
  end
end

# frozen_string_literal: true
require 'rails_helper'

RSpec.describe WithProxyForObject::Factory do
  subject { described_class.new(members) }
  let(:members) do
    [
      instance_double(ScannedResource, id: "test", to_s: "Banana")
    ]
  end

  it "can be used to build nodes for a logical order recursively" do
    obj = subject.new({ "nodes": [{ label: "Chapter 1" }] }, nil)
    expect(obj).to respond_to :proxy_for_object
    expect(obj.nodes.first).to respond_to :proxy_for_object
  end
end

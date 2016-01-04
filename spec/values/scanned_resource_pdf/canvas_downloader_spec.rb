require 'rails_helper'

RSpec.describe ScannedResourcePDF::CanvasDownloader, vcr: { cassette_name: "iiif_manifest" } do
  subject { described_class.new(canvas) }
  let(:canvas) do
    c = instance_double ScannedResourcePDF::Canvas
    allow(c).to receive(:url).and_return(path)
    allow(c).to receive(:width).and_return(width)
    allow(c).to receive(:height).and_return(height)
    c
  end
  let(:path) { "http://192.168.99.100:5004/x6%2F33%2Ff1%2F04%2Fn-intermediate_file.jp2" }
  let(:width) { 700 }
  let(:height) { 800 }
  describe "#layout" do
    context "when height is bigger" do
      it "returns portrait" do
        expect(subject.layout).to eq :portrait
      end
    end
    context "when width is bigger" do
      let(:width) { 900 }
      it "returns landscape" do
        expect(subject.layout).to eq :landscape
      end
    end
  end

  describe "#download" do
    it "returns an IO object" do
      expect(subject.download).to respond_to(:read)
    end
  end
end

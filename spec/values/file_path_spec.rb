require 'rails_helper'

RSpec.describe FilePath do
  subject { described_class.new(path_uri) }
  let(:path_uri) { "file:///bla/test/Test.tiff" }

  describe "#uri" do
    it "returns the uri" do
      expect(subject.uri).to eq path_uri
    end
  end

  describe "#clean" do
    it "returns the URI without the file schema" do
      expect(subject.clean).to eq "/bla/test/Test.tiff"
    end
  end
  context "when given a path with a space in it" do
    let(:path_uri) { "file:///bla bla/test/Test.tiff" }
    describe "#uri" do
      it "returns the uri" do
        expect(subject.uri).to eq path_uri
      end
    end

    describe "#clean" do
      it "returns the URI without the file schema" do
        expect(subject.clean).to eq "/bla bla/test/Test.tiff"
      end
    end
  end
end

require 'rails_helper'

RSpec.describe FileSet do
  subject { described_class.new.tap { |x| x.apply_depositor_metadata("bob") } }

  describe "#viewing_hint" do
    it "has the right predicate" do
      expect(described_class.properties["viewing_hint"].predicate).to eq ::RDF::Vocab::IIIF.viewingHint
    end
  end

  describe "validations" do
    it "validates with the viewing hint validator" do
      expect(subject._validators[nil].map(&:class)).to include ViewingHintValidator
    end
  end

  describe "iiif_path" do
    it "returns the manifest path" do
      allow(subject).to receive(:id).and_return("1")

      expect(subject.iiif_path).to eq "http://192.168.99.100:5004/1-intermediate_file.jp2"
    end
  end

  describe "#create_derivatives" do
    let(:path) { Pathname.new(PairtreeDerivativePath.derivative_path_for_reference(subject, 'intermediate_file')) }
    let(:ocr_path) { Pathname.new(PairtreeDerivativePath.derivative_path_for_reference(subject, 'ocr')) }
    it "creates a JP2" do
      allow_any_instance_of(described_class).to receive(:warn) # suppress virus check warnings
      file = File.open(Rails.root.join("spec", "fixtures", "files", "color.tif"))
      Hydra::Works::UploadFileToFileSet.call(subject, file)

      subject.create_derivatives(file.path)

      expect(path).to exist
    end
    it "creates full text" do
      allow_any_instance_of(described_class).to receive(:warn) # suppress virus check warnings
      allow(Hydra::Derivatives::Jpeg2kImageDerivatives).to receive(:create).and_return(true)
      file = File.open(Rails.root.join("spec", "fixtures", "files", "page18.tif"))
      Hydra::Works::UploadFileToFileSet.call(subject, file)

      subject.create_derivatives(file.path)

      expect(ocr_path).to exist
    end
    after do
      FileUtils.rm_rf(path.parent) if path.exist?
      FileUtils.rm_rf(ocr_path.parent) if ocr_path.exist?
    end
  end
end

require 'rails_helper'

RSpec.describe FileSet do
  subject { described_class.new.tap { |x| x.apply_depositor_metadata("bob") } }

  describe "metadata" do
    context "singular" do
      { 'viewing_hint' => ::RDF::Vocab::IIIF.viewingHint,
        'identifier' => ::RDF::Vocab::DC.identifier,
        'source_metadata_identifier' => ::PULTerms.metadata_id,
        'replaces' => ::RDF::Vocab::DC.replaces
      }.each do |attribute, predicate|
        describe "##{attribute}" do
          it "has the right predicate" do
            expect(described_class.properties[attribute].predicate).to eq predicate
          end
          it "disallows multiple values" do
            expect(described_class.properties[attribute].multiple?).to eq false
          end
        end
      end
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

  it "can persist" do
    expect { subject.save! }.not_to raise_error
  end

  describe "#create_derivatives" do
    let(:path) { Pathname.new(PairtreeDerivativePath.derivative_path_for_reference(subject, 'intermediate_file')) }
    let(:thumbnail_path) { Pathname.new(PairtreeDerivativePath.derivative_path_for_reference(subject, 'thumbnail')) }
    let(:ocr_path) { Pathname.new(PairtreeDerivativePath.derivative_path_for_reference(subject, 'ocr')) }
    it "doesn't create a thumbnail" do
      allow_any_instance_of(described_class).to receive(:warn) # suppress virus check warnings
      file = File.open(Rails.root.join("spec", "fixtures", "files", "color.tif"))
      Hydra::Works::UploadFileToFileSet.call(subject, file)
      subject.create_derivatives(file.path)

      expect(thumbnail_path).not_to exist
    end
    it "creates a JP2" do
      allow_any_instance_of(described_class).to receive(:warn) # suppress virus check warnings
      file = File.open(Rails.root.join("spec", "fixtures", "files", "color.tif"))
      Hydra::Works::UploadFileToFileSet.call(subject, file)

      subject.create_derivatives(file.path)

      expect(path).to exist
    end
    it "copies a JP2" do
      allow_any_instance_of(described_class).to receive(:warn) # suppress virus check warnings
      file = File.open(Rails.root.join("spec", "fixtures", "files", "image.jp2"))
      Hydra::Works::UploadFileToFileSet.call(subject, file)

      subject.create_derivatives(file.path)

      expect(path).to exist
    end
    it "creates full text, attaches it to the object, and indexes it" do
      allow_any_instance_of(described_class).to receive(:warn) # suppress virus check warnings
      allow(Hydra::Derivatives::Jpeg2kImageDerivatives).to receive(:create).and_return(true)
      file = File.open(Rails.root.join("spec", "fixtures", "files", "page18.tif"))
      Hydra::Works::UploadFileToFileSet.call(subject, file)
      allow_any_instance_of(HOCRDocument).to receive(:text).and_return("yo")
      allow(Plum.config).to receive(:[]).with(:store_original_files).and_return(true)
      allow(Plum.config).to receive(:[]).with(:create_hocr_files).and_return(true)
      allow(Plum.config).to receive(:[]).with(:index_hocr_files).and_return(true)

      subject.create_derivatives(file.path)

      expect(ocr_path).to exist
      expect(subject.to_solr["full_text_tesim"]).to eq "yo"

      # verify that ocr has been added to the FileSet
      subject.reload
      expect(subject.files.size).to eq(2)
      expect(subject.files.to_a.find { |x| x.mime_type != "image/tiff" }.content).to include "<div class='ocr_page'"
    end
    it "does not create full text if OCR is disabled in configuration." do
      allow_any_instance_of(described_class).to receive(:warn) # suppress virus check warnings
      allow(Hydra::Derivatives::Jpeg2kImageDerivatives).to receive(:create).and_return(true)
      file = File.open(Rails.root.join("spec", "fixtures", "files", "page18.tif"))
      Hydra::Works::UploadFileToFileSet.call(subject, file)
      allow_any_instance_of(HOCRDocument).to receive(:text).and_return("yo")
      allow(Plum.config).to receive(:[]).with(:store_original_files).and_return(true)
      allow(Plum.config).to receive(:[]).with(:create_hocr_files).and_return(false)

      subject.create_derivatives(file.path)

      expect(ocr_path).not_to exist
    end
    it "creates full text from text file when provided." do
      allow_any_instance_of(described_class).to receive(:warn) # suppress virus check warnings
      text_file = File.open(Rails.root.join("spec", "fixtures", "files", "fulltext.txt"))
      Hydra::Works::UploadFileToFileSet.call(subject, text_file)
      allow(Plum.config).to receive(:[]).with(:store_original_files).and_return(true)
      allow(Plum.config).to receive(:[]).with(:create_hocr_files).and_return(false)
      allow(Plum.config).to receive(:[]).with(:index_hocr_files).and_return(false)

      subject.create_derivatives(text_file.path)

      expect(ocr_path.sub(".hocr", ".txt")).to exist
      expect(subject.to_solr["full_text_tesim"]).to include "OCR text file."
    end
    after do
      FileUtils.rm_rf(path.parent) if path.exist?
      FileUtils.rm_rf(ocr_path.parent) if ocr_path.exist?
    end
  end
end

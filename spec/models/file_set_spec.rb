require 'rails_helper'

RSpec.describe FileSet do
  around { |example| perform_enqueued_jobs(&example) }

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

  it "can persist" do
    expect { subject.save! }.not_to raise_error
  end

  describe "#create_derivatives" do
    let(:delivery_service) { instance_double(GeoWorks::DeliveryService) }

    before do
      allow(delivery_service).to receive(:publish)
      allow(GeoWorks::DeliveryService).to receive(:new).and_return(delivery_service)
    end

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
      allow(subject.characterization_proxy).to receive(:mime_type_storage).and_return(["image/tiff"])

      subject.create_derivatives(file.path)

      expect(path).to exist
    end
    it "creates full text and indexes it" do
      allow_any_instance_of(described_class).to receive(:warn) # suppress virus check warnings
      allow(Hydra::Derivatives::Jpeg2kImageDerivatives).to receive(:create).and_return(true)
      file = File.open(Rails.root.join("spec", "fixtures", "files", "page18.tif"))
      Hydra::Works::UploadFileToFileSet.call(subject, file)
      allow_any_instance_of(HOCRDocument).to receive(:text).and_return("yo")
      allow(subject.characterization_proxy).to receive(:mime_type_storage).and_return(["image/tiff"])

      subject.create_derivatives(file.path)

      expect(ocr_path).to exist
      expect(subject.to_solr["full_text_tesim"]).to eq "yo"
    end
    it "creates a vector thumbnail and indexes the path" do
      allow_any_instance_of(described_class).to receive(:warn) # suppress virus check warnings
      subject.geo_mime_type = 'application/vnd.geo+json'
      file = File.open(Rails.root.join("spec", "fixtures", "files", "mercer.json"))
      Hydra::Works::UploadFileToFileSet.call(subject, file)
      subject.create_derivatives(file.path)

      expect(subject.to_solr['thumbnail_path_ss']).to match(/file=thumbnail/)
    end
    after do
      FileUtils.rm_rf(path.parent) if path.exist?
      FileUtils.rm_rf(ocr_path.parent) if ocr_path.exist?
    end
  end

  describe '#where' do
    let(:file_set) { FactoryGirl.create(:file_set) }
    let(:parent) { FactoryGirl.create(:scanned_resource) }
    let(:user) { FactoryGirl.create(:admin) }
    let(:file) { File.open(Rails.root.join("spec", "fixtures", "files", "gray.tif")) }
    let(:sha1) { 'b1477526078bdcfca2b2e209d929018be1bc9219' }

    before do
      FileSetActor.new(file_set, user).attach_content(file)
      file_set.update_index
      allow(CreateDerivativesJob).to receive(:perform_later)
    end

    it 'retrieves a fileset by the original file checksum' do
      expect(described_class.where(digest_ssim: "urn:sha1:#{sha1}").first).to_not be_nil
      expect(described_class.where(digest_ssim: "urn:sha1:#{sha1}").first.id).to eq(file_set.id)
    end
  end

  describe '#metadata_xml' do
    let(:xml_file) { Rails.root.join('spec', 'fixtures', 'voyager-2028405.xml') }
    it 'will read the local file for its XML' do
      expect(subject).to receive(:local_file) { xml_file }
      expect(subject.send(:metadata_xml)).to be_kind_of Nokogiri::XML::Document
    end
  end

  describe '#destroy' do
    let(:file_set) { FactoryGirl.create(:file_set, label: 'gray.tif') }
    let(:parent) { FactoryGirl.create(:scanned_resource) }
    let(:user) { FactoryGirl.create(:admin) }
    let(:file) { File.open(Rails.root.join("spec", "fixtures", "files", "gray.tif")) }

    before do
      FileSetActor.new(file_set, user).attach_content(file)
      file_set.update_index
      allow(CreateDerivativesJob).to receive(:perform_later)
    end

    it 'removes files' do
      expect(FileUtils).to receive(:rm_rf).with(file_set.local_file)
      file_set.destroy
    end
  end
end

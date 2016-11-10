require 'rails_helper'

RSpec.describe PreingestJob do
  let(:user) { FactoryGirl.build(:admin) }
  shared_examples "successfully preingests" do
    it "writes the expected yaml output" do
      yaml_content = File.open(yaml_file) { |f| Psych.load(f) }
      yaml_content[:sources][0][:file] = Rails.root.join(yaml_content[:sources][0][:file]).to_s
      expect(File).to receive(:write).with(yaml_file, yaml_content.to_yaml)
      described_class.perform_now(document_class, preingest_file, user)
    end
  end

  describe "preingesting a METS file" do
    let(:mets_file_single) { Rails.root.join("spec", "fixtures", "pudl_mets", "pudl0001-4612596.mets").to_s }
    let(:mets_file_rtl) { Rails.root.join("spec", "fixtures", "pudl_mets", "pudl0032-ns73.mets").to_s }
    let(:mets_file_multi) { Rails.root.join("spec", "fixtures", "pudl_mets", "pudl0001-4609321-s42.mets").to_s }
    let(:yaml_file) { preingest_file.sub(/\.mets$/, '.yml') }
    let(:document_class) { PreingestableMETS }

    context "with a single-volume mets file", vcr: { cassette_name: 'bibdata-bhr9405' } do
      let(:preingest_file) { mets_file_single }
      include_examples "successfully preingests"
    end
    context "with a right-to-left mets file", vcr: { cassette_name: 'bibdata-bhr9405' } do
      let(:preingest_file) { mets_file_rtl }
      include_examples "successfully preingests"
    end
    context "preingests a multi-volume yaml file", vcr: { cassette_name: 'bibdata-bhr9405' } do
      let(:preingest_file) { mets_file_multi }
      include_examples "successfully preingests"
    end
  end
  describe "preingesting a Variations file" do
    let(:variations_file_single) { Rails.root.join("spec", "fixtures", "variations_xml", "bhr9405.xml").to_s }
    let(:variations_file_multi) { Rails.root.join("spec", "fixtures", "variations_xml", "abe9721.xml").to_s }
    let(:yaml_file) { preingest_file.sub(/\.xml$/, '.yml') }
    let(:document_class) { VariationsDocument }

    context "with a single-volume Variations file", vcr: { cassette_name: 'bibdata-bhr9405' } do
      let(:preingest_file) { variations_file_single }
      include_examples "successfully preingests"
    end

    context "with a multi-volume Variations file", vcr: { cassette_name: 'bibdata-abe9721' } do
      let(:preingest_file) { variations_file_multi }
      include_examples "successfully preingests"
    end
  end
  describe "preingest a contentDM file" do
    let(:cdm_file_multiple) { Rails.root.join("spec", "fixtures", "contentdm_xml", "Irish_People.xml").to_s }
    let(:yaml_file) { preingest_file.sub(/\.xml$/, '.yml') }
    let(:document_class) { ContentdmExport }

    context "with a multi-volume CDM XML export file" do
      let(:preingest_file) { cdm_file_multiple }
      include_examples "successfully preingests"
    end
  end
end

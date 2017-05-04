require 'rails_helper'

RSpec.describe EphemeraFolderPresenter do
  let(:folder) { FactoryGirl.build(:ephemera_folder) }

  let(:blacklight_config) do
    double(
      show_fields: { field: Blacklight::Configuration::Field.new(field: :identifier) },
      index_fields: { field: Blacklight::Configuration::Field.new(field: :identifier) },
      view_config: double("struct", title_field: :identifier)
    )
  end
  let(:controller) { double(blacklight_config: blacklight_config) }
  subject { described_class.new(SolrDocument.new(folder.to_solr), controller) }

  describe "#language" do
    context "when given a set of language IDs" do
      after do
        Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("languages")
      end
      before do
        Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("languages")
        vocabulary
      end
      let(:vocabulary) do
        Vocabulary.create!(label: "languages").tap do |vocab|
          VocabularyTerm.create!(vocabulary: vocab, label: "English")
          VocabularyTerm.create!(vocabulary: vocab, label: "Japanese")
        end
      end
      let(:folder) { FactoryGirl.build(:ephemera_folder, language: [VocabularyTerm.first.id.to_s]) }
      it "Returns the label for the IDs" do
        expect(subject.language).to eq ["English"]
      end
    end
  end

  describe "#renderer_for" do
    it "renders identifier as a barcodde" do
      expect(subject.renderer_for(:identifier, {})).to be BarcodeAttributeRenderer
    end

    it "renders title as a regular attribute" do
      expect(subject.renderer_for(:title, {})).to be Hyrax::Renderers::AttributeRenderer
    end
  end
end

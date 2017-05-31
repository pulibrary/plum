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

  describe "#genre" do
    context "when given a set of genre IDs" do
      after do
        Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Genre")
      end
      before do
        Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Genre")
        vocabulary
      end
      let(:vocabulary) do
        Vocabulary.create!(label: "Genre").tap do |vocab|
          VocabularyTerm.create!(vocabulary: vocab, label: "English")
          VocabularyTerm.create!(vocabulary: vocab, label: "Japanese")
        end
      end
      let(:folder) { FactoryGirl.build(:ephemera_folder, genre: [VocabularyTerm.first.id.to_s]) }
      it "Returns the label for the IDs" do
        expect(subject.genre).to eq ["English"]
      end
    end
  end

  describe "#geographic_origin" do
    context "when given a set of geographic IDs" do
      after do
        Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Geographic Origin")
      end
      before do
        Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Geographic Origin")
        vocabulary
      end
      let(:vocabulary) do
        Vocabulary.create!(label: "Geographic Origin").tap do |vocab|
          VocabularyTerm.create!(vocabulary: vocab, label: "English")
          VocabularyTerm.create!(vocabulary: vocab, label: "Japanese")
        end
      end
      let(:folder) { FactoryGirl.build(:ephemera_folder, geographic_origin: [VocabularyTerm.first.id.to_s]) }
      it "Returns the label for the IDs" do
        expect(subject.geographic_origin).to eq ["English"]
      end
    end
  end

  describe "#geo_subject" do
    context "when given a set of genre IDs" do
      after do
        Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Geographic Origin")
      end
      before do
        Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Geographic Origin")
        vocabulary
      end
      let(:vocabulary) do
        Vocabulary.create!(label: "Geographic Origin").tap do |vocab|
          VocabularyTerm.create!(vocabulary: vocab, label: "English")
          VocabularyTerm.create!(vocabulary: vocab, label: "Japanese")
        end
      end
      let(:folder) { FactoryGirl.build(:ephemera_folder, geo_subject: [VocabularyTerm.first.id.to_s]) }
      it "Returns the label for the IDs" do
        expect(subject.geo_subject).to eq ["English"]
      end
    end

    context "when there's no vocabulary" do
      let(:folder) { FactoryGirl.build(:ephemera_folder, geo_subject: ["Test"]) }
      it "works" do
        expect(subject.geo_subject).to eq ["Test"]
      end
    end
  end

  describe "#subject" do
    context "when given a set of genre IDs" do
      after do
        Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Subjects")
        Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Test")
      end
      before do
        Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Subjects")
        Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Test")
        vocabulary
      end
      let(:vocabulary) do
        Vocabulary.create!(label: "Subjects").tap do |vocab|
          Vocabulary.create!(label: "Test", parent: vocab).tap do |vocab_2|
            VocabularyTerm.create!(vocabulary: vocab_2, label: "English")
          end
        end
      end
      let(:folder) { FactoryGirl.build(:ephemera_folder, subject: [VocabularyTerm.first.id.to_s]) }
      it "Returns the label for the IDs" do
        expect(subject.subject).to eq ["English"]
      end
    end

    context "when there's no vocabulary" do
      let(:folder) { FactoryGirl.build(:ephemera_folder, subject: ["Test"]) }
      it "works" do
        expect(subject.subject).to eq ["Test"]
      end
    end
  end
end

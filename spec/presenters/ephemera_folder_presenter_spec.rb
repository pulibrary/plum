require 'rails_helper'

RSpec.describe EphemeraFolderPresenter do
  let(:folder) { FactoryGirl.build(:ephemera_folder, id: 'abcd1234', language: [term.id.to_s]) }
  let(:box) { FactoryGirl.create(:ephemera_box, ephemera_project: [project.id]) }
  let(:project) { FactoryGirl.create(:ephemera_project) }
  let(:term) { FactoryGirl.create(:vocabulary_term, label: "English") }

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
        EphemeraField.create! ephemera_project: project, name: "EphemeraFolder.language", vocabulary: vocabulary
        folder.member_of_collections = [box]
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
        EphemeraField.create! ephemera_project: project, name: "EphemeraFolder.genre", vocabulary: vocabulary
        folder.member_of_collections = [box]
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
        EphemeraField.create! ephemera_project: project, name: "EphemeraFolder.geographic_origin", vocabulary: vocabulary
        folder.member_of_collections = [box]
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
        EphemeraField.create! ephemera_project: project, name: "EphemeraFolder.geo_subject", vocabulary: vocabulary
        folder.member_of_collections = [box]
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
        EphemeraField.create! ephemera_project: project, name: "EphemeraFolder.subject", vocabulary: vocabulary
        folder.member_of_collections = [box]
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

  describe "linked data" do
    let(:folder) { FactoryGirl.create(:ephemera_folder, id: 'abcd1234', language: [term.id.to_s], height: ['123'], width: ['456'], page_count: ['789'], sort_title: ['example folder'], date_uploaded: Time.now, date_modified: Time.now) }

    it 'generates json-ld with descriptive metadata' do
      json = JSON.parse(subject.export_as_jsonld)
      expect(json["@id"]).to eq("http://plum.com/concern/ephemera_folders/abcd1234")
      expect(json["title"]).to eq("Example Folder")
      expect(json["edm_rights"]["@id"]).to eq("http://rightsstatements.org/vocab/NKC/1.0/")
      expect(json["edm_rights"]["pref_label"]).to eq("No Known Copyright")
      expect(json["@type"]).to eq("pcdm:Object")
      expect(json["barcode"]).to eq("32101091980639")
      expect(json["label"]).to eq("Folder 3")
      expect(json['height']).to eq('123')
      expect(json['width']).to eq('456')
      expect(json['page_count']).to eq('789')
      expect(json['sort_title']).to eq(['example folder'])
      expect(json['created']).not_to be_nil
      expect(json['modified']).not_to be_nil

      lang = json["language"].first
      expect(lang["@id"]).to eq(Rails.application.class.routes.url_helpers.vocabulary_term_url(term.id))
      expect(lang["pref_label"]).to eq("English")
      expect(lang["exact_match"]["@id"]).to eq("http://id.loc.gov/authorities/subjects/sh85077482")
    end

    it 'does not fail when values are not controlled' do
      folder.genre = ['foo']
      json = JSON.parse(subject.export_as_jsonld)
      expect(json["dcterms_type"]).to eq(['foo'])
    end

    it 'does not fail when lookups fail' do
      folder.genre = ['0000000']
      json = JSON.parse(subject.export_as_jsonld)
      expect(json["dcterms_type"]).to eq(['0000000'])
    end
  end
end

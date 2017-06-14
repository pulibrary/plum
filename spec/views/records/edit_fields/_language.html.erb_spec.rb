require 'rails_helper'
include SimpleForm::ActionViewExtensions::FormHelper

RSpec.describe 'records/edit_fields/_language.html.erb' do
  let(:project) { FactoryGirl.create :ephemera_project }
  let(:box) { FactoryGirl.create :ephemera_box, ephemera_project: [project.id] }
  let(:vocabulary_label) { "Languages" }
  before do
    allow(view).to receive(:f).and_return(simple_form_for(form))
    allow(view).to receive(:key).and_return(:language)
    allow(view).to receive(:params).and_return(parent_id: box.id)
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete(vocabulary_label)
  end
  after do
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete(vocabulary_label)
  end

  context 'with an ephemera folder' do
    let(:folder) { FactoryGirl.build(:ephemera_folder, member_of_collections: [box]) }
    let(:form) { Hyrax::EphemeraFolderForm.new(folder, nil, nil) }
    let(:vocabulary) do
      Vocabulary.create!(label: vocabulary_label).tap do |vocab|
        VocabularyTerm.create!(vocabulary: vocab, label: "English")
        VocabularyTerm.create!(vocabulary: vocab, label: "Japanese")
      end
    end
    let(:form) { Hyrax::EphemeraFolderForm.new(folder, nil, nil) }
    context "when there is no language vocabulary" do
      before do
        render
      end
      it "doesn't create a select box" do
        expect(rendered).not_to have_selector "select"
      end
    end
    context "when there is a language vocabulary" do
      before do
        EphemeraField.create! name: "EphemeraFolder.language", ephemera_project: project, vocabulary: vocabulary
        render
      end
      it "creates a select box" do
        expect(rendered).to have_select("Language", options: ['', 'English', 'Japanese'])
      end
    end
  end

  context 'with a scanned resource' do
    let(:form) { Hyrax::ScannedResourceForm.new(ScannedResource.new, nil, nil) }
    let(:vocabulary) do
      Vocabulary.create!(label: "languages").tap do |vocab|
        VocabularyTerm.create!(vocabulary: vocab, label: "English")
        VocabularyTerm.create!(vocabulary: vocab, label: "Japanese")
      end
    end
    before do
      render
    end
    it "doesn't create a select box" do
      expect(rendered).not_to have_selector "select"
    end
  end
end

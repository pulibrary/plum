require 'rails_helper'
include SimpleForm::ActionViewExtensions::FormHelper

RSpec.describe 'records/edit_fields/_language.html.erb' do
  let(:vocabulary) { nil }
  before do
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("languages")
    allow(view).to receive(:f).and_return(simple_form_for(form))
    allow(view).to receive(:key).and_return(:language)
    vocabulary
    render
  end
  after do
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("languages")
  end

  context 'with an ephemera folder' do
    let(:form) { Hyrax::EphemeraFolderForm.new(EphemeraFolder.new, nil, nil) }
    context "when there is no language vocabulary" do
      it "doesn't create a select box" do
        expect(rendered).not_to have_selector "select"
      end
    end
    context "when there is a language vocabulary" do
      let(:vocabulary) do
        Vocabulary.create!(label: "languages").tap do |vocab|
          VocabularyTerm.create!(vocabulary: vocab, label: "English")
          VocabularyTerm.create!(vocabulary: vocab, label: "Japanese")
        end
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
    it "doesn't create a select box" do
      expect(rendered).not_to have_selector "select"
    end
  end
end

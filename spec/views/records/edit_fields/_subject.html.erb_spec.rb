require 'rails_helper'
include SimpleForm::ActionViewExtensions::FormHelper

RSpec.describe 'records/edit_fields/_subject.html.erb' do
  let(:vocabulary) { nil }
  let(:vocabulary_label) { "Subjects" }
  before do
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete(vocabulary_label)
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Test")
    allow(view).to receive(:f).and_return(simple_form_for(form))
    allow(view).to receive(:key).and_return(:subject)
    vocabulary
    render
  end
  after do
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete(vocabulary_label)
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete("Test")
  end

  context 'with an ephemera folder' do
    let(:form) { Hyrax::EphemeraFolderForm.new(EphemeraFolder.new, nil, nil) }
    context "when there is no subject vocabulary" do
      it "doesn't create a select box" do
        expect(rendered).not_to have_selector "select"
      end
    end
    context "when there is a subject vocabulary" do
      let(:vocabulary) do
        Vocabulary.create!(label: "Subjects").tap do |vocab|
          Vocabulary.create!(label: "Test", parent: vocab).tap do |vocab_2|
            VocabularyTerm.create!(vocabulary: vocab_2, label: "English")
          end
        end
      end
      let(:folder) { FactoryGirl.build(:ephemera_folder, subject: [VocabularyTerm.first.id.to_s]) }
      it "creates a select box" do
        expect(rendered).to have_select("Subject", options: ['', 'English'])
      end
    end
  end
end

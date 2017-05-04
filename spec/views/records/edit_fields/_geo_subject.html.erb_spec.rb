require 'rails_helper'
include SimpleForm::ActionViewExtensions::FormHelper

RSpec.describe 'records/edit_fields/_geo_subject.html.erb' do
  let(:vocabulary) { nil }
  let(:vocabulary_label) { "Geographic Origin" }
  before do
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete(vocabulary_label)
    allow(view).to receive(:f).and_return(simple_form_for(form))
    allow(view).to receive(:key).and_return(:geo_subject)
    vocabulary
    render
  end
  after do
    Qa::Authorities::Local.registry.instance_variable_get(:@hash).delete(vocabulary_label)
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
        Vocabulary.create!(label: vocabulary_label).tap do |vocab|
          VocabularyTerm.create!(vocabulary: vocab, label: "Ireland")
          VocabularyTerm.create!(vocabulary: vocab, label: "Japan")
        end
      end
      it "creates a select box" do
        expect(rendered).to have_select("Geo subject", options: ['', 'Ireland', 'Japan'])
      end
    end
  end
end

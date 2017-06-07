require 'rails_helper'
include SimpleForm::ActionViewExtensions::FormHelper

RSpec.describe 'records/edit_fields/_subject.html.erb' do
  let(:project) { FactoryGirl.create :ephemera_project }
  let(:box) { FactoryGirl.create :ephemera_box, ephemera_project: [project.id] }
  let(:folder) { FactoryGirl.build(:ephemera_folder, member_of_collections: [box], subject: [term.id]) }
  let(:form) { Hyrax::EphemeraFolderForm.new(folder, nil, nil) }
  let(:vocabulary) { Vocabulary.create!(label: "Subjects") }
  let(:subvocab) { Vocabulary.create!(label: "Test", parent: vocabulary) }
  let(:term) { VocabularyTerm.create!(vocabulary: subvocab, label: "English") }
  before do
    allow(view).to receive(:f).and_return(simple_form_for(form))
    allow(view).to receive(:key).and_return(:subject)
    allow(view).to receive(:params).and_return(parent_id: box.id)
  end

  context 'with an ephemera folder' do
    context "when there is no subject vocabulary" do
      before do
        render
      end
      it "doesn't create a select box" do
        expect(rendered).not_to have_selector "select"
      end
    end
    context "when there is a subject vocabulary" do
      before do
        EphemeraField.create! name: "EphemeraFolder.subject", ephemera_project: project, vocabulary: vocabulary
        render
      end
      it "creates a select box" do
        expect(rendered).to have_select("Subject", options: ['', 'English'])
      end
    end
  end
end

require 'rails_helper'

RSpec.describe CurationConcerns::FileSetsController do
  let(:file_set) { FactoryGirl.build(:file_set) }
  let(:parent) { FactoryGirl.create(:scanned_resource) }
  let(:user) { FactoryGirl.create(:admin) }
  let(:file) { fixture_file_upload("files/color.tif", "image/tiff") }
  describe "#update" do
    before do
      sign_in user
      file_set.save
    end
    it "can update viewing_hint" do
      allow_any_instance_of(described_class).to receive(:parent_id).and_return(nil)
      patch :update, id: file_set.id, file_set: { viewing_hint: 'non-paged' }
      expect(file_set.reload.viewing_hint).to eq 'non-paged'
    end
    it "redirects to the containing scanned resource after editing" do
      allow_any_instance_of(described_class).to receive(:parent).and_return(parent)
      patch :update, id: file_set.id, file_set: { viewing_hint: 'non-paged' }
      expect(response).to redirect_to(Rails.application.class.routes.url_helpers.file_manager_curation_concerns_scanned_resource_path(parent.id))
    end
  end

  describe "#create" do
    before do
      sign_in user
    end
    it "sends an update message for the parent" do
      manifest_generator = instance_double(ManifestEventGenerator, record_updated: true)
      allow(ManifestEventGenerator).to receive(:new).and_return(manifest_generator)
      allow(IngestFileJob).to receive(:perform_later).and_return(true)
      allow(CharacterizeJob).to receive(:perform_later).and_return(true)
      xhr :post, :create, parent_id: parent,
                          file_set: { files: [file],
                                      title: ['test title'],
                                      visibility: 'restricted' }

      expect(FileSet.all.length).to eq 1
      expect(manifest_generator).to have_received(:record_updated).with(parent)
    end
  end
end

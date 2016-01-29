require 'rails_helper'

RSpec.describe CurationConcerns::FileSetsController do
  let(:file_set) { FactoryGirl.build(:file_set) }
  let(:parent) { FactoryGirl.create(:scanned_resource) }
  let(:user) { FactoryGirl.create(:admin) }
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
      expect(response).to redirect_to(Rails.application.class.routes.url_helpers.bulk_edit_curation_concerns_scanned_resource_path(parent.id))
    end
  end
end

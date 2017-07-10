require 'rails_helper'

describe Hyrax::ConfirmController do
  let(:user) { FactoryGirl.create(:admin) }
  let(:public) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:private) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
  let(:parent) { FactoryGirl.create :metadata_review_multi_volume_work, visibility: public, members: [member] }
  let(:member) { FactoryGirl.create :pending_scanned_resource, visibility: private }

  before do
    sign_in user
  end

  describe '#copy_state' do
    it 'copies state from the parent to the member' do
      expect {
        post :copy_state, params: { id: parent.id }
      }.to have_enqueued_job(CopyStateJob)
    end
  end

  describe '#copy_visibility' do
    it 'copies visibility from the parent to the member' do
      expect {
        post :copy_visibility, params: { id: parent.id }
      }.to have_enqueued_job(CopyVisibilityJob)
    end
  end
end

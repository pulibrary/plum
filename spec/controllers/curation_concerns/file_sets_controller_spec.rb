require 'rails_helper'

RSpec.describe CurationConcerns::FileSetsController do
  let(:file_set) { FactoryGirl.build(:file_set) }
  let(:user) { FactoryGirl.create(:admin) }
  describe "#update" do
    before do
      sign_in user
      file_set.save
    end
    it "can update viewing_hint" do
      patch :update, id: file_set.id, file_set: { viewing_hint: 'non-paged' }
      expect(file_set.reload.viewing_hint).to eq 'non-paged'
    end
  end
end

require 'rails_helper'

RSpec.describe Workflow::InitializeComment do
  let(:user) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:scanned_resource) }
  let(:entity) { FactoryGirl.create(:sipity_entity, proxy_for_global_id: work.to_global_id.to_s) }
  let(:comment) { 'test comment' }

  before do
    Sipity::Agent.create(proxy_for_id: user.id, proxy_for_type: "User")
  end

  describe '#call' do
    it 'creates a sipity comment' do
      described_class.call(entity, user, comment)
      expect(Sipity::Comment.all.first.comment).to eq comment
    end
  end
end

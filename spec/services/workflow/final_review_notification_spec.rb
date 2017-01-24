require 'rails_helper'

RSpec.describe Workflow::FinalReviewNotification do
  let(:approver) { FactoryGirl.build(:user) }
  let(:work) { FactoryGirl.create(:scanned_resource) }
  let(:entity) { FactoryGirl.build(:sipity_entity, proxy_for_global_id: work.to_global_id.to_s) }

  before do
    ActionMailer::Base.deliveries = []
  end

  around { |example| perform_enqueued_jobs(&example) }

  describe ".send_notification" do
    it 'sends a message to all users' do
      described_class.send_notification(entity: entity, user: approver, comment: nil, recipients: {})
      expect(ActionMailer::Base.deliveries.first.subject).to eq "[plum] Scanned Resource #{work.id}: Final Review"
    end
  end
end

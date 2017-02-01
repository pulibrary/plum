require 'rails_helper'

RSpec.describe Workflow::CompleteNotification do
  let(:approver) { FactoryGirl.build(:user) }
  let(:to_user) { FactoryGirl.build(:user) }
  let(:cc_user) { FactoryGirl.build(:user) }
  let(:title) { RDF::Literal.new('Test title', language: :en) }
  let(:work) { FactoryGirl.create(:scanned_resource, title: [title]) }
  let(:entity) { FactoryGirl.build(:sipity_entity, proxy_for_global_id: work.to_global_id.to_s) }
  let(:comment) { double("comment", comment: 'A pleasant read') }
  let(:recipients) { { 'to' => [to_user], 'cc' => [cc_user] } }

  before do
    ActionMailer::Base.deliveries = []
  end

  around { |example| perform_enqueued_jobs(&example) }

  describe ".send_notification" do
    it 'sends a message to all users' do
      expect { described_class.send_notification(entity: entity, user: approver, comment: comment, recipients: recipients) }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.first.from).to eq ['plum@princeton.edu']
      expect(ActionMailer::Base.deliveries.first.to).to include(to_user.email, cc_user.email, approver.email)
      expect(ActionMailer::Base.deliveries.first.subject).to eq "[plum] Scanned Resource #{work.id}: Complete"
      expect(ActionMailer::Base.deliveries.first.to_s)
        .to include("The following Scanned Resource has been moved to Complete by #{approver.user_key}:")
    end
  end

  describe 'handles RDF::Literal titles' do
    it 'uses the value' do
      expect(described_class.new(entity, nil, approver, []).title).to eq(title.to_s)
    end
  end
end

require "rails_helper"

RSpec.describe ReviewerMailer, type: :mailer do
  describe '#completion_email' do
    let(:curation_concern) { FactoryGirl.create(:scanned_resource) }
    before(:each) do
      ActionMailer::Base.deliveries = []
      described_class.completion_email(curation_concern.id).deliver_now
    end

    it 'sends an email' do
      expect(ActionMailer::Base.deliveries.count).to eq 1
      expect(ActionMailer::Base.deliveries.first.from).to eq ['plum@princeton.edu']
      expect(ActionMailer::Base.deliveries.first.to).to eq [Plum.config[:email][:reviewer_address]]
      expect(ActionMailer::Base.deliveries.first.subject).to eq "[plum] #{curation_concern.human_readable_type} #{curation_concern.id} is complete"
    end
  end
end

require "rails_helper"

RSpec.describe ReviewerMailer, type: :mailer do
  describe '#notify' do
    let(:curation_concern) { FactoryGirl.create(:scanned_resource) }
    let(:complete_reviewer) { FactoryGirl.create(:complete_reviewer) }
    let(:takedown_reviewer) { FactoryGirl.create(:takedown_reviewer) }

    before do
      ActionMailer::Base.deliveries = []
      curation_concern.save
      complete_reviewer.save
      takedown_reviewer.save
    end

    context "complete" do
      before(:each) do
        described_class.notify(curation_concern.id, 'complete').deliver_now
      end

      it 'sends an email to complete_reviewer' do
        expect(ActionMailer::Base.deliveries.count).to eq 1
        expect(ActionMailer::Base.deliveries.first.from).to eq ['pumpkin@iu.edu']
        expect(ActionMailer::Base.deliveries.first.to).to eq [complete_reviewer.email]
        expect(ActionMailer::Base.deliveries.first.subject).to eq "[plum] #{curation_concern.human_readable_type} #{curation_concern.id}: complete"
      end
    end

    context "takedown" do
      before(:each) do
        described_class.notify(curation_concern.id, 'takedown').deliver_now
      end

      it 'sends an email to takedown_reviewer' do
        expect(ActionMailer::Base.deliveries.count).to eq 1
        expect(ActionMailer::Base.deliveries.first.from).to eq ['pumpkin@iu.edu']
        expect(ActionMailer::Base.deliveries.first.to).to eq [takedown_reviewer.email]
        expect(ActionMailer::Base.deliveries.first.subject).to eq "[plum] #{curation_concern.human_readable_type} #{curation_concern.id}: takedown"
      end
    end

    context "pending" do
      before(:each) do
        described_class.notify(curation_concern.id, 'pending').deliver_now
      end

      it 'does not send any notifications' do
        expect(ActionMailer::Base.deliveries.count).to eq 0
      end
    end

    context "multiple addresses" do
      before(:each) do
        allow_any_instance_of(Role).to receive(:users).and_return([complete_reviewer, takedown_reviewer])
        described_class.notify(curation_concern.id, 'takedown').deliver_now
      end

      it 'sends one email to both complete_reviewer and takedown_reviewer' do
        expect(ActionMailer::Base.deliveries.count).to eq 1
        expect(ActionMailer::Base.deliveries.first.from).to eq ['pumpkin@iu.edu']
        expect(ActionMailer::Base.deliveries.first.to).to eq [complete_reviewer.email, takedown_reviewer.email]
        expect(ActionMailer::Base.deliveries.first.subject).to eq "[plum] #{curation_concern.human_readable_type} #{curation_concern.id}: takedown"
      end
    end
  end
end

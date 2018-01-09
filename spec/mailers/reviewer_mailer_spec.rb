# frozen_string_literal: true
require "rails_helper"

RSpec.describe ReviewerMailer, type: :mailer do
  describe '#notify' do
    let(:recipient_1) { 'user1@example.com' }
    let(:recipient_2) { 'user2@example.com' }
    let(:args) { {
      subject: 'subject',
      message: 'message',
      title: 'title',
      work_id: 'work_id',
      addresses: addresses,
      url: 'https://plum/concern/scanned_resource/pg704gxr4b'
    } }

    before do
      ActionMailer::Base.deliveries = []
    end

    context "singe address" do
      let(:addresses) { [recipient_1] }

      before do
        described_class.notify(args).deliver_now
      end

      it 'sends one email to recipient' do
        expect(ActionMailer::Base.deliveries.count).to eq 1
        expect(ActionMailer::Base.deliveries.first.from).to eq ['plum@princeton.edu']
        expect(ActionMailer::Base.deliveries.first.to).to eq ['user1@example.com']
        expect(ActionMailer::Base.deliveries.first.subject).to eq "subject"
      end
    end

    context "multiple addresses" do
      let(:addresses) { [recipient_1, recipient_2] }

      before do
        described_class.notify(args).deliver_now
      end

      it 'sends one email to recipient' do
        expect(ActionMailer::Base.deliveries.count).to eq 1
        expect(ActionMailer::Base.deliveries.first.from).to eq ['plum@princeton.edu']
        expect(ActionMailer::Base.deliveries.first.to).to eq ['user1@example.com', 'user2@example.com']
        expect(ActionMailer::Base.deliveries.first.subject).to eq "subject"
      end
    end
  end
end

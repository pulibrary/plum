require 'rails_helper'

RSpec.describe GeoblacklightMessagingClient do
  subject { described_class.new(url) }
  let(:url) { "amqp://test.x.z.s:4000" }
  let(:config) { { 'events' => { 'exchange' => { 'geoblacklight' => 'gbl_events' } } } }
  let(:message) { { exchange: :geoblacklight }.to_json }
  let(:channel) { instance_double(Bunny::Channel) }
  let(:bunny_session) { instance_double(Bunny::Session, create_channel: channel) }
  let(:exchange) { double }

  describe '#publish' do
    context 'with a valid bunny connection' do
      before do
        allow(Bunny).to receive(:new).and_return(bunny_session)
        allow(bunny_session).to receive(:start)
      end

      it 'calls publish on the rabbit exchange' do
        expect(channel).to receive(:fanout).and_return(exchange)
        expect(exchange).to receive(:publish).with(message, persistent: true)
        subject.publish(message)
      end
    end

    context 'with an invalid bunny connection' do
      let(:log_message) { "Unable to publish message to #{url}" }

      before do
        allow(Bunny).to receive(:new).and_raise(StandardError)
      end

      it 'logs an error' do
        expect(Rails.logger).to receive(:warn).with(log_message)
        subject.publish(message)
      end
    end
  end
end

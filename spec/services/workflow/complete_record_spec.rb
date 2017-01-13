require 'rails_helper'

RSpec.describe Workflow::CompleteRecord do
  let(:complete_record_obj) { instance_double('CompleteRecord') }
  let(:depositor) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:scanned_resource, depositor: depositor.user_key) }
  let(:user) { User.new }

  describe '.call' do
    it 'adds edit access to groups' do
      expect(CompleteRecord).to receive(:new).with(work).and_return(complete_record_obj)
      expect(complete_record_obj).to receive(:complete)
      described_class.call(target: work)
    end
  end
end

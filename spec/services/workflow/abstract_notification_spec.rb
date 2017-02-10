require 'rails_helper'

RSpec.describe Workflow::AbstractNotification do
  let(:work) { FactoryGirl.create(:scanned_resource) }
  let(:entity) { FactoryGirl.build(:sipity_entity, proxy_for_global_id: work.to_global_id.to_s) }

  describe '#state' do
    it 'raises an error because the class should not be instantiated directly' do
      expect { described_class.send_notification(entity: entity, user: nil, comment: nil, recipients: nil) }
        .to raise_error(/Implement #state/)
    end
  end
end

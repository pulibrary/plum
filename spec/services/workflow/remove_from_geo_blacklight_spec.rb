require 'rails_helper'

RSpec.describe Workflow::RemoveFromGeoBlacklight do
  let(:work) { FactoryGirl.create(:vector_work) }
  let(:messenger) { instance_double(GeoWorks::EventsGenerator) }

  describe '#call' do
    before do
      allow(GeoWorks::Messaging).to receive(:messenger).and_return(messenger)
    end

    it 'removes target work from geoblacklight' do
      expect(messenger).to receive(:record_deleted).with(instance_of(VectorWorkShowPresenter))
      described_class.call(target: work)
    end
  end
end

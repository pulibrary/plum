require 'rails_helper'

RSpec.describe Workflow::PublishToGeoBlacklight do
  let(:work) { FactoryGirl.create(:vector_work) }
  let(:messenger) { instance_double(GeoWorks::EventsGenerator) }

  describe '#call' do
    before do
      allow(GeoWorks::Messaging).to receive(:messenger).and_return(messenger)
    end

    it 'updates geoblacklight with the target work' do
      expect(messenger).to receive(:record_updated).with(instance_of(VectorWorkShowPresenter))
      described_class.call(target: work)
    end
  end
end

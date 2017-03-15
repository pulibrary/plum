require 'rails_helper'

RSpec.describe Workflow::RemoveFromGeoBlacklight do
  let(:work) { FactoryGirl.create(:vector_work) }
  let(:generator) { instance_double(GeoWorks::EventsGenerator) }

  describe '#call' do
    before do
      allow(GeoWorks::EventsGenerator).to receive(:new).and_return(generator)
    end

    it 'removes target work from geoblacklight' do
      expect(generator).to receive(:record_deleted).with(instance_of(VectorWorkShowPresenter))
      described_class.call(target: work)
    end
  end
end

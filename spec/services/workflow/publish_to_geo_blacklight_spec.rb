# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Workflow::PublishToGeoBlacklight do
  let(:work) { FactoryGirl.create(:vector_work) }
  let(:generator) { instance_double(GeoWorks::EventsGenerator) }

  describe '#call' do
    before do
      allow(GeoWorks::EventsGenerator).to receive(:new).and_return(generator)
    end

    it 'updates geoblacklight with the target work' do
      expect(generator).to receive(:record_updated).with(instance_of(VectorWorkShowPresenter))
      described_class.call(target: work)
    end
  end
end

# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::VectorWorksController, admin_set: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:vector_work) { FactoryGirl.create(:complete_vector_work, user: user) }
  let(:manifest_generator) { instance_double(GeoWorks::EventsGenerator) }

  before do
    allow(GeoWorks::EventsGenerator).to receive(:new).and_return(manifest_generator)
  end

  describe '#show_presenter' do
    subject { described_class.new.show_presenter }
    it { is_expected.to eq(VectorWorkShowPresenter) }
  end

  describe '#delete' do
    before do
      sign_in user
    end

    it 'fires a delete event' do
      expect(manifest_generator).to receive(:record_deleted)
      delete :destroy, params: { id: vector_work }
    end
  end

  describe '#update' do
    let(:vector_work_attributes) do
      FactoryGirl.attributes_for(:vector_work).merge(
        title: ['New Title']
      )
    end

    before do
      sign_in user
    end

    context 'with a complete state' do
      it 'fires an update event' do
        expect(manifest_generator).to receive(:record_updated)
        post :update, params: { id: vector_work, vector_work: vector_work_attributes }
      end
    end

    context 'with a non-complete state' do
      let(:vector_work) { FactoryGirl.create(:pending_vector_work, user: user) }
      it 'does not fire an update event' do
        expect(manifest_generator).not_to receive(:record_updated)
        post :update, params: { id: vector_work, vector_work: vector_work_attributes }
      end
    end
  end

  describe '#geoblacklight' do
    # Tell RSpec where to find the geoblacklight route.
    routes { GeoWorks::Engine.routes }
    let(:builder) { instance_double(GeoWorks::Discovery::DocumentBuilder, to_hash: { id: 'test' }) }
    let(:document) { instance_double(Discovery::GeoblacklightDocument) }
    before do
      sign_in user
      allow(Discovery::GeoblacklightDocument).to receive(:new).and_return(document)
    end

    it 'uses the plum document builder class' do
      expect(GeoWorks::Discovery::DocumentBuilder).to receive(:new).with(anything, document).and_return(builder)
      get :geoblacklight, params: { id: vector_work.id, format: :json }
    end
  end
end

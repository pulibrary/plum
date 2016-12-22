require 'rails_helper'

describe CurationConcerns::VectorWorksController do
  let(:state) { 'complete' }
  let(:user) { FactoryGirl.create(:user) }
  let(:vector_work) { FactoryGirl.create(:vector_work, state: state, user: user) }
  let(:manifest_generator) { instance_double(GeoConcerns::EventsGenerator) }

  before do
    allow(GeoConcerns::EventsGenerator).to receive(:new).and_return(manifest_generator)
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
      delete :destroy, id: vector_work
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
        post :update, id: vector_work, vector_work: vector_work_attributes
      end
    end

    context 'with a non-complete state' do
      let(:state) { 'final_review' }
      it 'does not fire an update event' do
        expect(manifest_generator).to_not receive(:record_updated)
        post :update, id: vector_work, vector_work: vector_work_attributes
      end
    end
  end
end

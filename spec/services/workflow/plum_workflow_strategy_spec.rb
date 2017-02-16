require 'rails_helper'

RSpec.describe Workflow::PlumWorkflowStrategy, :no_clean do
  context 'when working with a scanned resource' do
    let(:work) { FactoryGirl.build(:scanned_resource) }
    let(:workflow_strategy) { described_class.new(work, nil) }

    describe '#workflow_id' do
      subject { workflow_strategy.workflow_id }
      it { is_expected.to eq Sipity::Workflow.where(name: 'book_works').first!.id }
    end
  end

  context 'when working with a vector work' do
    let(:work) { FactoryGirl.build(:vector_work) }
    let(:workflow_strategy) { described_class.new(work, nil) }

    describe '#workflow_name' do
      subject { workflow_strategy.workflow_id }
      it { is_expected.to eq Sipity::Workflow.where(name: 'geo_works').first!.id }
    end
  end
end

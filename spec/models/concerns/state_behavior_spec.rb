require 'rails_helper'

describe StateBehavior, :admin_set do
  describe "when there is no sipity entity" do
    let(:sipityless_resource) { Stateful.new }
    before do
      class Stateful
        include StateBehavior
      end
    end
    after do
      Object.send(:remove_const, :Stateful)
    end
    it "does not result in an error" do
      expect(sipityless_resource.workflow_state).to be nil
    end
  end

  describe "an in-memory resource" do
    let(:memory_resource) { FactoryGirl.build(:scanned_resource) }
    it "has no state" do
      expect(memory_resource.workflow_state).to be nil
    end
  end

  describe "an uninitialized resource" do
    let(:uninitialized_resource) { FactoryGirl.create(:scanned_resource) }
    it "has no state" do
      expect(uninitialized_resource.workflow_state).to be nil
    end
  end

  describe "an uninitialized resource" do
    let(:initialized_resource) { FactoryGirl.create(:scanned_resource) }
    before do
      Workflow::InitializeState.call(initialized_resource, 'book_works', 'pending')
    end
    it "has a state" do
      expect(initialized_resource.workflow_state).to eq('pending')
    end
  end
end

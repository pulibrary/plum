require 'rails_helper'

RSpec.describe MembershipService do
  let(:resource) { FactoryGirl.create(:scanned_resource_in_collection) }
  let(:from_collection) { resource.member_of_collections.first }
  let(:to_collection) { FactoryGirl.create(:collection, title: ['To Collection']) }

  context "managing collection membership" do
    it "copies membership" do
      described_class.copy_membership(from_collection, to_collection)
      expect(resource.reload.member_of_collections).to contain_exactly(from_collection, to_collection)
    end

    it "transfer membership" do
      described_class.transfer_membership(from_collection, to_collection)
      expect(resource.reload.member_of_collections).to contain_exactly(to_collection)
    end
  end
end

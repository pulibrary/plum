require 'rails_helper'

RSpec.describe MembershipBuilder do
  subject { described_class.new(scanned_resource, members) }
  let(:scanned_resource) { FactoryGirl.create(:scanned_resource) }
  let(:members) { [FactoryGirl.create(:file_set), FactoryGirl.create(:file_set), FactoryGirl.create(:file_set)] }
  let(:appended) { [FactoryGirl.create(:file_set), FactoryGirl.create(:file_set)] }
  let(:reloaded) { scanned_resource.reload }

  describe "#attach_files_to_work" do
    it "apppends file_sets to a work" do
      subject.attach_files_to_work
      expect(reloaded.ordered_member_ids.length).to eq 3
      described_class.new(reloaded, appended).attach_files_to_work
      expect(reloaded.ordered_member_ids.length).to eq 5
    end
  end
end

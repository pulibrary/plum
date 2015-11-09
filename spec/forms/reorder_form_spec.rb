require 'rails_helper'

RSpec.describe ReorderForm do
  subject { described_class.new(curation_concern) }
  let(:curation_concern) { FactoryGirl.build(:scanned_resource) }

  describe "validations" do
    context "when it has members" do
      let(:member) { FactoryGirl.create(:file_set) }
      let(:member_2) { FactoryGirl.create(:file_set) }
      before do
        curation_concern.ordered_members << member
        curation_concern.ordered_members << member_2
      end
      it "is valid without changes" do
        expect(subject).to be_valid
      end
      it "is valid when an order is set with the same number" do
        subject.order = [member_2.id, member.id]

        expect(subject).to be_valid
      end
      it "can validate independent orders" do
        subject.order = [member_2.id, member.id]
        expect(subject).to be_valid

        new_curation_concern = FactoryGirl.build(:scanned_resource)
        new_curation_concern.ordered_members += [member, member_2, member_2]
        new_form = described_class.new(new_curation_concern)
        new_form.order = [member_2.id, member_2.id, member]
        expect(new_form).to be_valid
      end
    end
  end
end

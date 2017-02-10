require 'rails_helper'

RSpec.describe ResourceIdentifier do
  around { |example| perform_enqueued_jobs(&example) }

  subject { described_class.new(scanned_resource.id) }
  let(:scanned_resource) { FactoryGirl.create(:scanned_resource) }

  describe "#to_s" do
    it "returns an identifier" do
      expect(subject.to_s).to be_kind_of String
    end
    it "changes when a file is added" do
      old_id = subject.to_s
      scanned_resource.ordered_members << FactoryGirl.create(:file_set)
      scanned_resource.save
      subject.reload

      expect(subject.to_s).not_to eq old_id
    end
    it "changes when reordered" do
      file_set1 = FactoryGirl.create(:file_set)
      file_set2 = FactoryGirl.create(:file_set)
      scanned_resource.ordered_members << file_set1
      scanned_resource.ordered_members << file_set2
      scanned_resource.save
      old_id = subject.to_s

      actor = CurationConcerns::CurationConcern.actor(scanned_resource, FactoryGirl.build(:user))
      actor.update("ordered_member_ids" => [file_set2.id, file_set1.id])

      expect(subject.reload.to_s).not_to eq old_id
    end
    it "changes when a file set's changed" do
      file_set1 = FactoryGirl.create(:file_set)
      scanned_resource.ordered_members << file_set1
      scanned_resource.save
      old_id = subject.to_s

      file_set1.viewing_hint = "continuous"
      file_set1.save

      expect(subject.reload.to_s).not_to eq old_id
    end
    it "changes when a middle member is deleted" do
      file_set1 = FactoryGirl.create(:file_set)
      file_set2 = FactoryGirl.create(:file_set)
      file_set3 = FactoryGirl.create(:file_set)
      scanned_resource.ordered_members << file_set1
      scanned_resource.ordered_members << file_set2
      scanned_resource.ordered_members << file_set3
      scanned_resource.save
      file_set3.viewing_hint = "continuous"
      file_set3.save
      old_id = subject.to_s

      file_set2.destroy

      expect(subject.reload.to_s).not_to eq old_id
    end
  end
end

require 'rails_helper'

RSpec.describe PendingUpload, type: :model do
  subject { FactoryGirl.build(:pending_upload) }
  describe "#validations" do
    it "has a valid factory" do
      expect(subject).to be_valid
    end
    context "when curation_concern_id is blank" do
      it "is invalid" do
        subject.curation_concern_id = nil

        expect(subject).not_to be_valid
      end
    end
    context "when upload_set_id is blank" do
      it "is invalid" do
        subject.upload_set_id = nil

        expect(subject).not_to be_valid
      end
    end
    context "when file_name is blank" do
      it "is invalid" do
        subject.file_name = nil

        expect(subject).not_to be_valid
      end
    end
    context "when file_path is blank" do
      it "is invalid" do
        subject.file_path = nil

        expect(subject).not_to be_valid
      end
    end
  end
end

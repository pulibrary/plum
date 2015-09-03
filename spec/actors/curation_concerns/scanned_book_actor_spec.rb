# Generated via
#  `rails generate curation_concerns:work ScannedBook`
require 'rails_helper'

describe CurationConcerns::ScannedBookActor do
  let(:curation_concern) { FactoryGirl.create(:scanned_book) }
  let(:user) { FactoryGirl.create(:user) }
  let(:attributes) { {} }
  let(:actor) { described_class.new(curation_concern, user, attributes) }
  subject { actor }

  describe "create" do
    it "Triggers update metadata" do
      expect(curation_concern).to receive(:apply_external_metadata)
      subject.create
    end
  end

  describe "update" do
    it "Triggers update metadata if retrieve metadata is true" do
      expect(curation_concern).to receive(:apply_external_metadata)
      subject.update(refresh_metadata: true)
    end

    it "Does not require an argument" do
      expect(curation_concern).to_not receive(:apply_external_metadata)
      subject.update
    end
  end
end

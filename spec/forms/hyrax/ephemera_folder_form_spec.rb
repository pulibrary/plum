require 'rails_helper'

RSpec.describe Hyrax::EphemeraFolderForm do
  let(:work) { FactoryGirl.build(:ephemera_folder) }
  let(:form) { described_class.new(work, nil, nil) }

  describe "#primary_terms" do
    it "has primary terms" do
      expect(form.primary_terms).to eq(form.terms - [:member_of_collection_ids, :visibility])
    end
  end

  describe "#secondary_terms" do
    it "has no secondary terms" do
      expect(form.secondary_terms).to eq([])
    end
  end

  describe "#rights_statement" do
    context "when there is no rights statement" do
      let(:work) { FactoryGirl.build(:ephemera_folder, rights_statement: nil) }
      it "defaults to NKC" do
        expect(form.rights_statement).to eq "http://rightsstatements.org/vocab/NKC/1.0/"
      end
    end
    context "when there is a rights statement" do
      let(:work) { FactoryGirl.build(:ephemera_folder, rights_statement: ["test"]) }
      it "uses it" do
        expect(form.rights_statement).to eq "test"
      end
    end
  end
end

require 'rails_helper'

RSpec.describe EphemeraBoxPresenter do
  let(:box) { FactoryGirl.build(:ephemera_box) }
  let(:folder) { FactoryGirl.build(:ephemera_folder, member_of_collections: [box]) }

  let(:blacklight_config) do
    double(
      show_fields: { field: Blacklight::Configuration::Field.new(field: :identifier) },
      index_fields: { field: Blacklight::Configuration::Field.new(field: :identifier) },
      view_config: double("struct", title_field: :identifier)
    )
  end
  let(:controller) { double(blacklight_config: blacklight_config) }
  subject { described_class.new(SolrDocument.new(box.to_solr), controller) }

  describe "#member_presenters" do
    before do
      box.save
      folder.save
    end
    it "includes a presenter for the folder" do
      expect(subject.member_presenters.length).to eq 1
      expect(subject.member_presenters.first).to be_kind_of EphemeraFolderPresenter
    end
  end

  describe "#member_ids" do
    before do
      box.save
      folder.save
    end
    it "includes the id of the folder" do
      expect(subject.member_ids).to eq [folder.id]
    end
  end
end

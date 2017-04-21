require 'rails_helper'

RSpec.describe EphemeraFolderPresenter do
  let(:folder) { FactoryGirl.build(:ephemera_folder) }

  let(:blacklight_config) do
    double(
      show_fields: { field: Blacklight::Configuration::Field.new(field: :identifier) },
      index_fields: { field: Blacklight::Configuration::Field.new(field: :identifier) },
      view_config: double("struct", title_field: :identifier)
    )
  end
  let(:controller) { double(blacklight_config: blacklight_config) }
  subject { described_class.new(SolrDocument.new(folder.to_solr), controller) }

  describe "#renderer_for" do
    it "renders identifier as a barcodde" do
      expect(subject.renderer_for(:identifier, {})).to be BarcodeAttributeRenderer
    end

    it "renders title as a regular attribute" do
      expect(subject.renderer_for(:title, {})).to be Hyrax::Renderers::AttributeRenderer
    end
  end
end

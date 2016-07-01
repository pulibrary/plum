require 'rails_helper'

RSpec.describe RTLShowPresenter do
  let(:document) do
    {
      field: ["بي", "one"]
    }
  end
  let(:blacklight_config) do
    double(
      show_fields: { field: Blacklight::Configuration::Field.new(field: :field) },
      index_fields: { field: Blacklight::Configuration::Field.new(field: :field) },
      view_config: double("struct", title_field: :field)
    )
  end
  let(:controller) { double(blacklight_config: blacklight_config) }
  subject { described_class.new(document, controller) }
  describe "#field_value" do
    context "when given a RTL string" do
      it "renders it as a RTL list item" do
        expect(subject.field_value(:field)).to eq "<ul><li dir=\"rtl\">بي</li><li dir=\"ltr\">one</li></ul>"
      end
    end
  end
end

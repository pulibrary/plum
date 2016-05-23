require 'rails_helper'

RSpec.describe RTLPresenter do
  let(:document) do
    {
      field: ["بي", "one"]
    }
  end
  let(:blacklight_config) do
    double(
      show_fields: { field: Blacklight::Configuration::Field.new(field: :field) },
      index_fields: { field: Blacklight::Configuration::Field.new(field: :field) }
    )
  end
  subject { described_class.new(document, double(blacklight_config: blacklight_config)) }
  describe "#render_document_show_field_value" do
    context "when given a RTL string" do
      it "renders it as a RTL list item" do
        expect(subject.render_document_show_field_value(:field)).to eq "<ul><li dir=\"rtl\">بي</li><li dir=\"ltr\">one</li></ul>"
      end
    end
  end
  describe "#render_index_field_value" do
    context "when given a RTL string" do
      it "renders it as a RTL list item" do
        expect(subject.render_index_field_value(:field)).to eq "<ul><li dir=\"rtl\">بي</li><li dir=\"ltr\">one</li></ul>"
      end
    end
  end
  describe "#render_document_index_label" do
    context "when given multiple items" do
      it "renders them as RTL list items" do
        expect(subject.render_document_index_label(:field)).to eq "<ul><li dir=\"rtl\">بي</li><li dir=\"ltr\">one</li></ul>"
      end
    end
  end
end

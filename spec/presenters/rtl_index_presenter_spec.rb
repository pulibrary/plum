# frozen_string_literal: true
require 'rails_helper'

RSpec.describe RTLIndexPresenter do
  subject { described_class.new(document, controller) }
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
  describe "#field_value" do
    context "when given a RTL string" do
      it "renders it as a RTL list item" do
        expect(subject.field_value(:field)).to eq "<ul><li dir=\"rtl\">بي</li><li dir=\"ltr\">one</li></ul>"
      end
    end
  end
  describe "#render_document_index_label" do
    context "when given multiple items from title field" do
      it "renders them as RTL list items" do
        expect(subject.label(:field)).to eq "<ul><li dir=\"rtl\">بي</li><li dir=\"ltr\">one</li></ul>"
      end
    end
    context "when given multiple items from a different field" do
      it "doesn't mess with it" do
        expect(subject.label("bla")).to eq "bla"
      end
    end
  end
end

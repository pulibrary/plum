require 'rails_helper'

describe "curation_concerns/scanned_books/_form_required_information.html.erb" do
  let(:curation_concern) { ScannedBook.new }
  before do
    form = simple_form_for([:curation_concerns, curation_concern])
    render partial: "curation_concerns/scanned_books/form_required_information", locals: {
      f: form
    }
  end
  context "when source metadata ID is not set" do
    it "has a title field" do
      expect(rendered).to have_selector "#scanned_book_title"
      expect(rendered).not_to have_selector "#scanned_book_title[readonly]"
    end
  end
  context "when source metadata ID is set" do
    let(:curation_concern) do
      ScannedBook.new do |x|
        x.source_metadata_identifier = "41"
      end
    end
    it "has a readonly title field" do
      expect(rendered).to have_selector "#scanned_book_title[readonly]"
    end
  end
end

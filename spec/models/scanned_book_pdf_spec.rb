require 'rails_helper'

describe ScannedBook do
  let(:page1) { FactoryGirl.create(:generic_file, content: fixture('files/pudl0032%2F267b%2F00000001.jpg')) }
  let(:page2) { FactoryGirl.create(:generic_file, content: fixture('files/pudl0032%2F267b%2F00000002.jpg')) }
  let(:page3) { FactoryGirl.create(:generic_file, content: fixture('files/pudl0032%2F267b%2F00000003.jpg')) }
  let(:page4) { FactoryGirl.create(:generic_file, content: fixture('files/pudl0032%2F267b%2F00000004.jpg')) }
  let(:book_with_pages) { FactoryGirl.create(:scanned_book, generic_files: [page1, page2, page3, page4]) }

  describe '#to_pdf' do
    let(:subject) { book_with_pages }
    let(:pdf) { subject.to_pdf }
    it 'generates a PDF document whose pages are the scanned book\'s generic_files' do
      expect(pdf.page_count).to eq 4
      # metadata_from_pdf = pdf.state.store.info.object
      # subject.send(:pdf_metadata).each_pair do |key,value|
      #   expect(metadata_from_pdf.encode("utf-16")).to include (value.encode("utf-16"))
      # end
    end
  end

  describe '#render_pdf' do
    let(:file_path) { "tmp/scanned_book_pdf.pdf" }
    it 'generates pdf and renders it to a file' do
      subject.render_pdf(file_path)
      rendered_pdf = File.open(file_path)
      expect(rendered_pdf.size).to be > 0
    end
  end
end

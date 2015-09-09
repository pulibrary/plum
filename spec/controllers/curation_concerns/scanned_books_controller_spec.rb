# Generated via
#  `rails generate curation_concerns:work ScannedBook`
require 'rails_helper'

describe CurationConcerns::ScannedBooksController do
  let(:user) { FactoryGirl.create(:user) }
  let(:scanned_book) { FactoryGirl.create(:scanned_book, user: user, title: ['Dummy Title']) }
  let(:reloaded) { scanned_book.reload }

  describe "create" do
    let(:user) { FactoryGirl.create(:admin) }
    before do
      sign_in user
    end
    context "when given a bib id", vcr: { cassette_name: 'bibdata', allow_playback_repeats: true } do
      let(:scanned_book_attributes) do
        FactoryGirl.attributes_for(:scanned_book).merge(
          source_metadata_identifier: "2028405"
        )
      end
      it "updates the metadata" do
        post :create, scanned_book: scanned_book_attributes
        s = ScannedBook.last
        expect(s.title).to eq ['The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.']
      end
    end
  end

  describe "#manifest" do
    context "when requesting JSON" do
      it "builds a manifest" do
        manifest_builder = instance_double ManifestBuilder
        book = instance_double(ScannedBook)
        allow(ScannedBook).to receive(:find).with("1").and_return(book)
        allow(ManifestBuilder).to receive(:new).with(book).and_return(manifest_builder)
        allow(manifest_builder).to receive(:to_json).and_return({ "hi" => 1 }.to_json)

        get :manifest, id: "1", format: :json

        expect(response.body).to eq({ "hi" => 1 }.to_json)
      end
    end
  end

  describe 'update' do
    let(:scanned_book_attributes) { { portion_note: 'Section 2', description: 'a description', source_metadata_identifier: '2028405' } }
    before do
      sign_in user
    end
    context 'by default' do
      it 'updates the record but does not refresh the exernal metadata' do
        post :update, id: scanned_book, scanned_book: scanned_book_attributes
        expect(reloaded.portion_note).to eq 'Section 2'
        expect(reloaded.title).to eq ['Dummy Title']
        expect(reloaded.description).to eq 'a description'
      end
    end
    context 'when :refresh_remote_metadata is set', vcr: { cassette_name: 'bibdata', allow_playback_repeats: true } do
      it 'updates remote metadata' do
        post :update, id: scanned_book, scanned_book: scanned_book_attributes, refresh_remote_metadata: true
        expect(reloaded.title).to eq ['The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.']
      end
    end
  end
end

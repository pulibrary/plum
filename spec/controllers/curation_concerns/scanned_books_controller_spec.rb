# Generated via
#  `rails generate curation_concerns:work ScannedBook`
require 'rails_helper'

describe CurationConcerns::ScannedBooksController do
  describe "create" do
    before do
      sign_in FactoryGirl.create(:admin)
    end
    context "when given a bib id", vcr: { cassette_name: 'bibdata', allow_playback_repeats: true } do
      it "updates the metadata" do
        post :create, scanned_book: FactoryGirl.attributes_for(:scanned_book).merge(
          source_metadata_identifier: "2028405"
        )

        s = ScannedBook.last
        expect(s.title).to eq ['The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.']
      end
    end
  end
end

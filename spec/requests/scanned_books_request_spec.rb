require 'rails_helper'

RSpec.describe 'ScannedBooksController', type: :request do
  let(:user) { FactoryGirl.create(:scanned_book_creator) }
  let(:scanned_book) { FactoryGirl.create(:scanned_book) }

  before do
    login_as(user, scope: :user)
  end

  it 'User creates a new scanned book', vcr: { cassette_name: 'bibdata', allow_playback_repeats: true }do
    get '/concern/scanned_books/new'

    expect(response).to render_template('curation_concerns/scanned_books/new')

    valid_params = {
      title: ['My Book'],
      source_metadata_identifier: '2028405',
      access_policy: 'something',
      use_and_reproduction: 'something else'
    }

    post '/concern/scanned_books', scanned_book: valid_params

    book_path = curation_concerns_scanned_book_path(assigns(:curation_concern))
    expect(response).to redirect_to(book_path)
    follow_redirect!

    expect(response).to render_template(:show)
    expect(response.status).to eq 200
    expect(response.body).to include('<h1>The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.')
  end
end

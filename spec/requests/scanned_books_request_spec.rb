require 'rails_helper'

RSpec.describe "ScannedBooksController", type: :request do

  let(:user) { FactoryGirl.create(:scanned_book_creator) }
  let(:scanned_book) { FactoryGirl.create(:scanned_book) }

  before do
    login_as(user, :scope => :user)
    stubbed_requests = Faraday::Adapter::Test::Stubs.new do |stub|
      response_body = fixture('voyager-2028405.xml').read
      stub.get('/2028405') { |env| [200, {}, response_body] }
    end
    stubbed_connection = Faraday.new do |builder|
      builder.adapter :test, stubbed_requests
    end
    allow(Faraday).to receive(:new).and_call_original  # allow calls to fedora, solr, etc to go through as normal.
    allow(Faraday).to receive(:new).with(:url => 'http://bibdata.princeton.edu/bibliographic/').and_return(stubbed_connection)
  end

  it "User creates a new scanned book" do
    get "/concern/scanned_books/new"

    expect(response).to render_template('curation_concerns/scanned_books/new')

    valid_params = {
      title: ["My Book"],
      source_metadata_identifier: "2028405",
      access_policy: "something",
      use_and_reproduction: "something else"
    }

    post "/concern/scanned_books", scanned_book: valid_params

    expect(response).to redirect_to(curation_concerns_scanned_book_path( assigns(:curation_concern) ))
    follow_redirect!

    expect(response).to render_template(:show)
    expect(response.status).to eq 200
    expect(response.body).to include("<h1>My Book")
  end
end

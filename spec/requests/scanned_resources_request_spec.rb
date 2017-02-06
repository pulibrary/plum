require 'rails_helper'

RSpec.describe 'ScannedResourcesController', type: :request do
  let(:user) { FactoryGirl.create(:image_editor) }

  before do
    login_as(user, scope: :user)
  end

  it 'User creates a new scanned resource', vcr: { cassette_name: 'bibdata', allow_playback_repeats: true } do
    get '/concern/scanned_resources/new'

    expect(response).to render_template('hyrax/scanned_resources/new')

    valid_params = {
      title: ['My Resource'],
      source_metadata_identifier: '2028405',
      rights_statement: 'http://rightsstatements.org/vocab/NKC/1.0/'
    }

    post '/concern/scanned_resources', params: { scanned_resource: valid_params }

    resource_path = hyrax_scanned_resource_path(assigns(:curation_concern))
    expect(response).to redirect_to(resource_path)
    follow_redirect!

    expect(response).to render_template(:show)
    expect(response.status).to eq 200
    expect(response.body).to include('<h1 dir="ltr">The Giant Bible of Mainz; 500th anniversary, April fourth, fourteen fifty-two, April fourth, nineteen fifty-two.</h1>')
  end
end

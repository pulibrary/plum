require 'rails_helper'

RSpec.describe Hyrax::DownloadsController do
  routes { Hyrax::Engine.routes }

  let(:user) { FactoryGirl.create(:admin) }
  let(:file_path) { fixture_path + '/files/test.pdf' }
  let(:file) { File.open(file_path) }
  let(:file_set) do
    FactoryGirl.create(:file_set, user: user)
  end

  before do
    allow(PairtreeDerivativePath).to receive(:derivative_path_for_reference).and_return(file_path)
  end

  describe 'grayscale pdf download' do
    before { sign_in user }

    it 'sends the file' do
      get :show, params: { id: file_set.to_param, file: 'gray-pdf' }
      expect(response.headers['Content-Length']).to eq file.size.to_s
    end
  end

  describe 'color pdf download' do
    before { sign_in user }

    it 'sends the file' do
      get :show, params: { id: file_set.to_param, file: 'color-pdf' }
      expect(response.headers['Content-Length']).to eq file.size.to_s
    end
  end

  describe 'default file download' do
    let(:default_file_path) { fixture_path + '/files/gray.tif' }
    let(:default_file) { File.open(default_file_path) }

    before do
      allow(file_set).to receive(:local_file).and_return(default_file_path)
      allow(ActiveFedora::Base).to receive(:find).and_return(file_set)
      sign_in user
    end

    it 'sends the default file' do
      get :show, params: { id: file_set.to_param }
      expect(response.headers['Content-Length']).to_not eq file.size.to_s
      expect(response.headers['Content-Length']).to eq default_file.size.to_s
    end
  end

  describe 'thumbnail download' do
    context 'with a non-geo file set' do
      it 'does not send the file' do
        get :show, params: { id: file_set.to_param, file: 'thumbnail' }
        expect(response.headers['Content-Length']).to_not eq file.size.to_s
        expect(response.content_type).to eq 'text/html'
      end
    end

    context 'with a geo file set' do
      let(:file_set) do
        FactoryGirl.create(:file_set, user: user, geo_mime_type: 'image/tiff')
      end
      it 'sends the file' do
        get :show, params: { id: file_set.to_param, file: 'thumbnail' }
        expect(response.headers['Content-Length']).to eq file.size.to_s
      end
    end
  end
end

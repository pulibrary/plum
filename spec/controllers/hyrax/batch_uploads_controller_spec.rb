require 'rails_helper'

RSpec.describe Hyrax::BatchUploadsController do
  routes { Hyrax::Engine.routes }

  let(:user) { FactoryGirl.create(:admin) }
  let(:batch_upload_item) do
    { keyword: [""], visibility: 'open', payload_concern: 'ImageWork' }
  end
  let(:post_params) do
    {
      uploaded_files: ['1'],
      batch_upload_item: batch_upload_item
    }
  end

  before { sign_in user }

  describe 'batch image work upload' do
    context 'with no upload files in params' do
      it 'redirects to root' do
        expect(BatchCreateJob).to_not receive(:perform_later)
        post :create
        expect(response).to redirect_to root_url
      end
    end

    context 'with upload file in params' do
      it 'uploads the file' do
        expect(BatchCreateJob).to receive(:perform_later)
        post :create, params: post_params
      end
    end
  end
end

# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::CollectionManifest do
  let(:user) { FactoryGirl.create(:admin) }
  let(:collection) do
    collection = MyCollection.new(id: '123', title: ['test title'])
    collection.save
    collection
  end
  let(:manifest_helper_class) { class_double(ManifestBuilder::ManifestHelper).as_stubbed_const(transfer_nested_constants: true) }
  let(:manifest_helper) { double }

  before do
    class MyCollection < ActiveFedora::Base
      include ::Hyrax::CollectionBehavior
      include Hyrax::BasicMetadata
    end

    class MyCollectionController < Hyrax::HyraxController
      include Hyrax::Manifest
      include Hyrax::CollectionManifest
      include Hyrax::CollectionsControllerBehavior

      self.curation_concern_type = MyCollection
    end

    routes.draw { get 'my_collection/index_manifest' => "my_collection#index_manifest" }
    @controller = MyCollectionController.new
    allow(@controller).to receive(:search_results).and_return([nil, [collection.to_solr]])

    allow(manifest_helper_class).to receive(:new).and_return(manifest_helper)
    allow(manifest_helper).to receive(:root_url).and_return("http://localhost")
  end

  after do
    Rails.application.reload_routes!
    Object.send(:remove_const, :MyCollection)
    Object.send(:remove_const, :MyCollectionController)
  end

  describe '#index_manifest' do
    context 'as an authenticated user' do
      before { sign_in user }

      it 'returns a valid manifest for a collection', manifest: true do
        get :index_manifest, params: { id: collection.id, format: :json }
        expect(response.status).to eq 200
        response_json = JSON.parse(response.body)
        expect(response_json).not_to be_empty
      end
    end

    context 'as an unauthenticated user' do
      let(:user) {}
      it 'returns a 401 status' do
        get :index_manifest, params: { id: collection.id, format: :json }
        expect(response.status).to eq 401
      end
    end

    context 'with an invalid manifest' do
      before do
        sign_in user
        allow(@controller).to receive(:all_manifests_builder).and_raise(ManifestBuilder::ManifestBuildError, 'Test error message')
      end

      it 'provides a 500 status code and serves an error message' do
        get :index_manifest, params: { id: collection.id, format: :json }
        expect(response.status).to eq 500
        response_json = JSON.parse(response.body)
        expect(response_json).to include 'message' => 'Test error message'
      end
    end

    context 'with an empty manifests' do
      let(:manifest) { instance_double(IIIF::Presentation::Manifest) }

      before do
        sign_in user
        allow(manifest).to receive(:to_json).and_return("{}")
        allow(@controller).to receive(:all_manifests_builder).and_raise(ManifestBuilder::ManifestEmptyError)
      end

      it 'provides a 404 status code and serves an empty JSON response' do
        get :index_manifest, params: { id: collection.id, format: :json }
        expect(response.status).to eq 404
        response_json = JSON.parse(response.body)
        expect(response_json).to be_empty
      end
    end
  end

  describe '#deny_access' do
    context 'as an unauthenticated user' do
      let(:user) {}
      it 'returns a 401 status' do
        get :index_manifest, params: { id: collection.id, format: :json }
        expect(response.status).to eq 401
      end
    end
  end
end

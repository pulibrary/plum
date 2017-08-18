require 'rails_helper'

RSpec.describe Hyrax::Manifest do
  let(:user) { FactoryGirl.create(:admin) }
  let(:work) do
    work = MyWork.new(id: '123', title: ['test title'])
    work.save
    work
  end

  before do
    class MyWork < ActiveFedora::Base
      include Hyrax::WorkBehavior
      include Hyrax::BasicMetadata
      self.valid_child_concerns = []
    end

    class MyWorkController < Hyrax::HyraxController
      include Hyrax::Manifest
      self.curation_concern_type = MyWork
    end

    class MyWorkShowPresenter < HyraxShowPresenter; end

    routes.draw { get 'my_work/manifest' => "my_work#manifest" }
    @controller = MyWorkController.new
    allow(@controller).to receive(:presenter).and_return(MyWorkShowPresenter.new(SolrDocument.new(work.to_solr), Ability.new(user)))
  end

  after do
    Rails.application.reload_routes!
    Object.send(:remove_const, :MyWork)
    Object.send(:remove_const, :MyWorkController)
  end

  describe '#manifest' do
    context 'as an authenticated user' do
      before { sign_in user }

      it 'returns a valid manifest for a work' do
        manifest_helper_class = class_double(ManifestBuilder::ManifestHelper).as_stubbed_const(transfer_nested_constants: true)
        manifest_helper = instance_double(ManifestBuilder::ManifestHelper)
        allow(manifest_helper).to receive(:polymorphic_url).and_return('http://localhost')
        allow(manifest_helper_class).to receive(:new).and_return(manifest_helper)

        get :manifest, params: { id: work.id, format: :json }
        expect(response.status).to eq 200
        response_json = JSON.parse(response.body)
        expect(response_json).not_to be_empty
      end
    end

    context 'as an unauthenticated user' do
      it 'returns a 401 status and an empty manifest for a work' do
        get :manifest, params: { id: work.id, format: :json }
        expect(response.status).to eq 401
        response_json = JSON.parse(response.body)
        expect(response_json).to be_empty
      end
    end

    context 'with an invalid manifest' do
      before do
        sign_in user
        allow(@controller).to receive(:manifest_builder).and_raise(ManifestBuilder::ManifestBuildError, 'Test error message')
      end

      it 'provides a 500 status code and serves an error message' do
        get :manifest, params: { id: work.id, format: :json }
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
        allow(@controller).to receive(:manifest_builder).and_raise(ManifestBuilder::ManifestEmptyError)
      end

      it 'provides a 404 status code and serves an empty JSON response' do
        get :manifest, params: { id: work.id, format: :json }
        expect(response.status).to eq 404
        response_json = JSON.parse(response.body)
        expect(response_json).to be_empty
      end
    end
  end

  describe '#deny_access' do
    context 'as an unauthenticated user' do
      it 'returns a 401 status and an empty manifest for a work' do
        get :manifest, params: { id: work.id, format: :json }
        expect(response).not_to be_success
        response_json = JSON.parse(response.body)
        expect(response_json).to be_empty
      end
    end
  end
end

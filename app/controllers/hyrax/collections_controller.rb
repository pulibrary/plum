# frozen_string_literal: true
class Hyrax::CollectionsController < ApplicationController
  include Hyrax::Manifest
  include Hyrax::CollectionManifest
  include Hyrax::CollectionsControllerBehavior
  skip_load_and_authorize_resource only: :index_manifest
  skip_before_action :authenticate_user!, only: [:index_manifest, :manifest]
  self.presenter_class = CollectionShowPresenter
  self.form_class = CollectionEditForm

  def current_ability
    ::Ability.new(current_user, auth_token: params[:auth_token])
  end
end

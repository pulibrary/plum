Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  mount BrowseEverything::Engine => '/browse'
  blacklight_for :catalog
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }, skip: [:passwords, :registration]
  devise_scope :user do
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
    get 'users/auth/cas', to: 'users/omniauth_authorize#passthru', defaults: { provider: :cas }, as: "new_user_session"
  end
  mount Hydra::RoleManagement::Engine => '/'

  resources :welcome, only: 'index'
  root to: 'welcome#index'
  # Add URL options
  default_url_options Rails.application.config.action_mailer.default_url_options

  # Collections have to go before CC routes, to add index_manifest.
  resources :collections, only: [] do
    member do
      get :manifest, defaults: { format: :json }
    end
    collection do
      get :manifest, defaults: { format: :json }, action: :index_manifest
    end
  end
  mount Hydra::Collections::Engine => '/'
  mount CurationConcerns::Engine, at: '/'
  curation_concerns_collections
  curation_concerns_basic_routes
  curation_concerns_embargo_management

  namespace :curation_concerns, path: :concern do
    resources :multi_volume_works, only: [] do
      member do
        get :manifest, defaults: { format: :json }
        post :flag
      end
    end
    resources :scanned_resources, only: [] do
      member do
        get :bulk_edit
        get :pdf
        get :structure
        post :structure, action: :save_structure
        get :manifest, defaults: { format: :json }
        post :reorder, action: :save_order
        post :browse_everything_files
        post :flag
      end
    end
  end

  namespace :curation_concerns, path: :concern do
    resources :scanned_resources, only: [:new, :create, :show], path: 'container/:parent_id/scanned_resources', as: 'member_scanned_resource'
  end
end

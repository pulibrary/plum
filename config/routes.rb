Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  mount BrowseEverything::Engine => '/browse'
  blacklight_for :catalog
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }, skip: [:passwords, :registration]
  devise_scope :user do
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
  mount Hydra::RoleManagement::Engine => '/'

  mount Hydra::Collections::Engine => '/'
  mount CurationConcerns::Engine, at: '/'
  resources :welcome, only: 'index'
  root to: 'welcome#index'
  curation_concerns_collections
  curation_concerns_basic_routes
  curation_concerns_embargo_management

  # Add URL options
  default_url_options Rails.application.config.action_mailer.default_url_options

  namespace :curation_concerns, path: :concern do
    resources :multi_volume_works, only: [] do
      member do
        get :manifest, defaults: { format: :json }
      end
    end
    resources :scanned_resources, only: [] do
      member do
        get :bulk_edit
        get :pdf
        get :manifest, defaults: { format: :json }
        post :reorder, action: :save_order
        post :browse_everything_files
      end
    end
  end

  namespace :curation_concerns, path: :concern do
    resources :scanned_resources, only: [:new, :create, :show], path: 'container/:parent_id/scanned_resources', as: 'member_scanned_resource'
  end
end

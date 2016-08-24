Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  mount BrowseEverything::Engine => '/browse'

  mount Blacklight::Engine => '/'
  concern :searchable, Blacklight::Routes::Searchable.new
  concern :exportable, Blacklight::Routes::Exportable.new
  resource :catalog, only: [:index], controller: 'catalog' do
    concerns :searchable
  end
  resources :bookmarks do
    concerns :exportable
    collection do
      delete 'clear'
    end
  end

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
  end
  mount CurationConcerns::Engine, at: '/'
  curation_concerns_collections
  curation_concerns_basic_routes
  curation_concerns_embargo_management

  get "/iiif/collections", defaults: { format: :json }, controller: :collections, action: :index_manifest

  namespace :curation_concerns, path: :concern do
    resources :parent, only: [] do
      [:multi_volume_works, :scanned_resources].each do |type|
        resources type, only: [] do
          member do
            get :file_manager
            get :structure
          end
        end
      end
    end
    resources :multi_volume_works, only: [] do
      member do
        get :manifest, defaults: { format: :json }
        post :flag
        post :browse_everything_files
        get :structure
        post :structure, action: :save_structure
      end
    end
    resources :scanned_resources, only: [] do
      member do
        get "/pdf/:pdf_quality", action: :pdf, as: :pdf
        get :structure
        post :structure, action: :save_structure
        get :manifest, defaults: { format: :json }
        post :browse_everything_files
        post :flag
      end
    end
    resources :file_sets, only: [] do
      member do
        post :derivatives
      end
    end
  end

  namespace :curation_concerns, path: :concern do
    resources :file_sets, only: [], path: 'container/:parent_id/file_sets', as: 'member_file_set' do
      member do
        get :text, defaults: { format: :json }
      end
    end
  end

  require 'sidekiq/web'
  authenticate :user do
    mount Sidekiq::Web => '/sidekiq'
  end

  # Dynamic robots.txt
  get '/robots.:format' => 'pages#robots'
end

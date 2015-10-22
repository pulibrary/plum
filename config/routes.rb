Rails.application.routes.draw do
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

  get '/concern/scanned_resources/:id/manifest', to: 'curation_concerns/scanned_resources#manifest', as: 'curation_concerns_scanned_resource_manifest', defaults: { format: :json }
  get '/concern/scanned_resources/:id/pdf', to: 'curation_concerns/scanned_resources#pdf', as: 'curation_concerns_scanned_resource_pdf'
end

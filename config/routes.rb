Rails.application.routes.draw do
  blacklight_for :catalog
  devise_for :users
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

  get '/concern/scanned_books/:id/manifest', to: 'curation_concerns/scanned_books#manifest', as: 'curation_concerns_scanned_book_manifest', defaults: { format: :json }
  get '/concern/scanned_books/:id/pdf', to: 'curation_concerns/scanned_books#pdf', as: 'curation_concerns_scanned_book_pdf'
end

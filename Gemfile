source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Modernizr.js library
gem 'modernizr-rails'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'curation_concerns', github:'projecthydra-labs/curation_concerns', branch: :master
gem 'pul_metadata_services', github:'pulibrary/pul_metadata_services', branch: :master
gem 'hydra-role-management', '~> 0.2.0'
gem 'rsolr', '~> 1.0.6'
gem 'devise'
gem 'devise-guests', '~> 0.3'
gem 'iiif-presentation'

# PDF generation
gem 'prawn'
# gem 'pdf-inspector', '~> 1.2.0', group: [:test]

# Copied from curation_concerns Gemfile.extra
gem 'hydra-collections', github: 'projecthydra/hydra-collections', branch: 'master'
gem 'hydra-works', github: 'projecthydra-labs/hydra-works', branch: 'master'
gem 'hydra-pcdm', github: 'projecthydra-labs/hydra-pcdm', branch: 'master'
gem 'activefedora-aggregation', github: 'projecthydra-labs/activefedora-aggregation', branch: 'master'
gem 'hydra-derivatives', github: 'projecthydra/hydra-derivatives', branch: 'master'
gem 'active-fedora', github: 'projecthydra/active_fedora', branch: 'master'

gem 'rubocop', require: false
gem 'rubocop-rspec', require: false

group :development, :test do
  gem 'simplecov', '~> 0.9', require: false
  gem 'coveralls', require: false
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem "factory_girl_rails"
  gem 'jasmine-rails'
  gem 'jasmine-jquery-rails'
  gem 'pdf-reader', github: 'yob/pdf-reader'
  gem 'pry-rails'
end

gem 'solr_wrapper', '~> 0.4'
gem 'fcrepo_wrapper', '~> 0.2'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-rails-console'
end

group :test do
  gem "capybara"
  gem "launchy"
  gem "vcr"
  gem "webmock", require: false
end

group :production do
  gem 'pg'
end
gem 'posix-spawn'
gem 'openseadragon'
gem 'sidekiq'
gem "omniauth-cas"
gem 'ezid-client'
gem 'sprockets-es6'
gem 'sprockets-rails', '~> 2.3.3'
gem 'browse-everything', github: 'projecthydra-labs/browse-everything', branch: 'bootstrap-sprockets'
gem 'aasm'
gem 'newrelic_rpm'
gem 'iso-639'
gem 'jettywrapper'
source 'https://rails-assets.org' do
  gem 'rails-assets-babel-polyfill'
  gem 'rails-assets-bootstrap-select', '1.9.4'
end

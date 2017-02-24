source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.1'
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

gem 'hyrax', github: 'projecthydra-labs/hyrax', branch: 'master'
gem 'pul_metadata_services', github:'pulibrary/pul_metadata_services', branch: 'pulfa-metadata'
gem 'hydra-role-management', '~> 0.2.0'
gem 'rsolr', '~> 1.1.0'
gem 'devise' , '~> 4.2.0'
gem 'devise-guests', '~> 0.3'
gem 'iiif-presentation', github: 'iiif/osullivan', branch: 'development'
gem 'geo_works', github: 'geoconcerns/geo_works', branch: 'master'

# PDF generation
gem 'prawn'
# gem 'pdf-inspector', '~> 1.2.0', group: [:test]

# Copied from hyrax Gemfile.extra
gem 'hydra-works', github: 'projecthydra-labs/hydra-works', branch: 'master'
gem 'hydra-pcdm', github: 'projecthydra-labs/hydra-pcdm', branch: 'master'
gem 'hydra-derivatives', '3.1.3'
gem 'active-fedora', '~> 11.1.2'
gem 'active-triples', '~> 0.11.0'
gem 'active_fedora-noid', '2.0.0'

gem 'rubocop', '~> 0.34.0', require: false
gem 'rubocop-rspec', '~> 1.3.0', require: false
gem 'rake', '11.3.0'

group :development, :test do
  gem 'simplecov', '~> 0.9', require: false
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem "factory_girl_rails"
  gem 'jasmine-rails'
  gem 'jasmine-jquery-rails'
  gem 'pdf-reader', github: 'yob/pdf-reader'
  gem 'pry-rails'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
  gem 'rails-controller-testing', require: false
end

gem 'solr_wrapper', '~> 0.18.0'
gem 'fcrepo_wrapper', '~> 0.6.0'
gem 'coveralls', '0.8.3', require: false

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'capistrano-rails-console'
  gem 'capistrano', '~> 3.7.1'
end

group :test do
  gem "capybara"
  gem "launchy"
  gem "vcr", '~> 2.9'
  gem "webmock", '~> 1.0', require: false
  gem "database_cleaner"
end

group :production do
  gem 'pg'
  gem 'dalli'
end
gem 'posix-spawn'
gem 'openseadragon'
gem 'sidekiq'
gem "omniauth-cas"
gem 'ezid-client'
gem 'sprockets-es6'
gem 'sprockets-rails', '~> 2.3.3'
gem 'sprockets', '~> 3.5.0'
gem 'browse-everything', github: 'projecthydra-labs/browse-everything'
gem 'aasm'
gem 'newrelic_rpm'
gem 'iso-639'
gem 'bunny'
gem 'string_rtl'
gem 'redis-namespace'
gem 'arabic-letter-connector'
group :staging, :development do
  gem 'ruby-prof'
end
gem 'rbtrace', require: false
gem 'pul_uv_rails', github: 'pulibrary/pul_uv_rails', branch: 'master'
gem 'grocer', github: 'pulibrary/grocer'
source 'https://rails-assets.org' do
  gem 'rails-assets-babel-polyfill'
  gem 'rails-assets-bootstrap-select', '1.9.4'
  gem 'rails-assets-jqueryui-timepicker-addon'
end
gem 'poltergeist'
gem 'tinymce-rails-imageupload', github: 'PerfectlyNormal/tinymce-rails-imageupload'
gem 'flipflop', github: 'voormedia/flipflop'

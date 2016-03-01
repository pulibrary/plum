# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'bundler/setup'
require 'rubocop/rake_task'
require 'solr_wrapper'
require 'fcrepo_wrapper'
require 'coveralls/rake/task'

Coveralls::RakeTask.new

require File.expand_path('../config/application', __FILE__)

Jettywrapper.hydra_jetty_version = 'v8.3.1'

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

desc 'Run test suite and style checker'
task spec: :rubocop do
  RSpec::Core::RakeTask.new(:spec)
end

task ci: ['jetty:clean'] do
  puts 'running continuous integration'
  jetty_params = Jettywrapper.load_config
  jetty_params[:startup_wait] = 90

  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end
  fail "test failures: #{error}" if error

  Rake::Task['coveralls:push'].invoke
end

namespace :server do
  desc 'Run Fedora and Solr for development environment'
  task :development do
    run_server 'development', solr_port: 8983, fcrepo_port: 8984
  end

  desc 'Run Fedora and Solr for test environment'
  task :test do
    run_server 'test', solr_port: 8985, fcrepo_port: 8986
  end
end

def run_server(environment, solr_port: nil, fcrepo_port: nil)
  solr_params = { port: solr_port, verbose: true, managed: true }
  fcrepo_params = { port: fcrepo_port, verbose: true, managed: true,
                    enable_jms: false, fcrepo_home_dir: "fcrepo4-#{environment}-data" }
  SolrWrapper.wrap(solr_params) do |solr|
    solr.with_collection(name: environment, dir: File.join(File.expand_path('.', File.dirname(__FILE__)), 'solr_conf', 'conf')) do
      FcrepoWrapper.wrap(fcrepo_params) do
        puts "\n#{environment.titlecase} servers running:\n"
        puts "    Fedora..: http://localhost:#{fcrepo_port}/rest/"
        puts "    Solr....: http://localhost:#{solr_port}/solr/#{environment}/"
        puts "\n^C to stop"
        sleep
      end
    end
  end
end

task default: :ci

Rails.application.load_tasks

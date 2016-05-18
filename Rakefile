# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'bundler/setup'
require 'rubocop/rake_task'
require 'solr_wrapper'
require 'fcrepo_wrapper'
require 'coveralls/rake/task'

Coveralls::RakeTask.new

require File.expand_path('../config/application', __FILE__)

desc 'Run RuboCop style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

desc 'Run ESLint style checker'
task :eslint do
  puts "Running eslint..."
  %(eslint "app/assets/javascripts/*.es6")
end

task spec: [:rubocop, :eslint]

task :ci do
  with_server 'test' do
    Rake::Task['spec'].invoke
  end
end

namespace :server do
  desc 'Run Fedora and Solr for development environment'
  task :development do
    with_server 'development' do
      begin
        sleep
      rescue Interrupt
        puts "Shutting down..."
      end
    end
  end
end

task default: :ci

Rails.application.load_tasks

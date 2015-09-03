# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'bundler/setup'
require 'rubocop/rake_task'
require 'jettywrapper'

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
end

task default: :ci

Rails.application.load_tasks

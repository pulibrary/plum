# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'rubocop/rake_task'

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

desc 'Run test suite and style checker'
task spec: :rubocop do
  RSpec::Core::RakeTask.new(:spec)
end

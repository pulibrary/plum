# frozen_string_literal: true
desc "Clear rails cache"
namespace :cache do
  task clear: :environment do
    puts "Clearing Rails cache"
    Rails.cache.clear
  end
end

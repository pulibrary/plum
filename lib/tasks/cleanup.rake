namespace :cleanup do
  task works: :environment do
    ids = ENV['IDS']
    ids.split(' ').each do |id|
      puts "destroying #{id}"
      ActiveFedora::Base.find(id).destroy
    end
  end
end

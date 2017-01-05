namespace :queue do
  task ingest: :environment do
    list_queue('ingest')
  end

  task default: :environment do
    list_queue('default')
  end
end

def list_queue(name)
  Sidekiq::Queue.new(name).each do |job|
    puts "#{job.args.first['job_class']} #{job.args.first['arguments'].select {|v| v.kind_of? String}}"
  end
end

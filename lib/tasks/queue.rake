namespace :queue do
  task ingest: :environment do
    list_queue('ingest')
  end

  task default: :environment do
    list_queue('default')
  end

  task retries: :environment do
    Sidekiq::RetrySet.new.select do |job|
      puts job_to_s(job)
    end
  end
end

def list_queue(name)
  Sidekiq::Queue.new(name).each do |job|
    puts job_to_s(job)
  end
end

def job_to_s(job)
  "#{job.args.first['job_class']} #{job.args.first['arguments'].select {|v| v.kind_of? String}} #{err(job)}"
end

def err(job)
  job['error_message']
end

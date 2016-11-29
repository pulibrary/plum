namespace :pmp do
  desc "Preingest one or more files of chosen type, in specified folder"
  task :preingest, [:document_type] => :environment do |task, args|
    abort "usage: rake preingest[document_type] /path/to/preingest/files" unless args.document_type
    begin
      document_class = "IuMetadata::Preingest::#{args.document_type.titleize}".constantize
    rescue
      abort "unknown preingest pipeline: #{args.document_type}"
    end
    user = User.find_by_user_key( ENV['USER'] ) if ENV['USER']
    user = User.all.select{ |u| u.admin? }.first unless user

    logger = Logger.new(STDOUT)
    PreingestJob.logger = logger
    logger.info "preingesting #{document_class::FILE_PATTERN} files from: #{ARGV[1]}"
    logger.info "preingesting as: #{user.user_key} (override with USER=foo)"
    abort "usage: rake preingest /path/to/preingest/files" unless ARGV[1] && Dir.exist?(ARGV[1])
    Dir["#{ARGV[1].chomp("/")}/**/#{document_class::FILE_PATTERN}"].each do |file|
      begin
        PreingestJob.perform_now(document_class, file, user)
      rescue => e
        puts "Error: #{e.message}"
        puts e.backtrace
      end
    end
  end
end

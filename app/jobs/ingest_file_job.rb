class IngestFileJob < ActiveJob::Base
  queue_as CurationConcerns.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] filepath the cached file within the CurationConcerns.config.working_path
  # @param [String,NilClass] mime_type
  # @param [User] user
  # @param [String] relation ('original_file')
  def perform(file_set, filepath, _user, opts = {})
    relation = opts.fetch(:relation, :original_file).to_sym

    # Wrap in an IO decorator to attach passed-in options
    local_file = Hydra::Derivatives::IoDecorator.new File.new(File::NULL)
    local_file.mime_type = "message/external-body; access-type=URL; url=\"#{local_file_url(file_set)}\""
    local_file.original_name = opts.fetch(:filename, File.basename(filepath))

    # Tell AddFileToFileSet service to skip versioning because versions will be minted by VersionCommitter (called by save_characterize_and_record_committer) when necessary
    Hydra::Works::AddFileToFileSet.call(file_set, local_file, relation, versioning: false)

    # Persist changes to the file_set
    file_set.save!
    file_set.in_works.each do |work|
      work.pending_uploads.where(file_name: local_file.original_name).destroy_all
    end

    repository_file = file_set.send(relation)
    CharacterizeJob.perform_later(file_set, repository_file.id, filepath)
  end

  def local_file_url(file_set)
    download_url(file_set)
  end

  def download_url(file_set)
    Plum.config[:file_url_module].constantize.download_url(file_set)
  end
end

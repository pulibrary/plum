class RunWordBoundariesJob < ActiveJob::Base
  queue_as :word_boundaries

  def perform(id)
    logger.info "WordBoundariesJob: #{id}"
    word_boundaries_runner = WordBoundariesRunner.new(id)
    if word_boundaries_runner.json_exists?
      logger.info "WordBoundaries already exists for #{id}"
    elsif word_boundaries_runner.hocr_exists?
      word_boundaries_runner.create
    else
      logger.info "WordBoundariesJob: Preconditions not met #{id}"
      RunWordBoundariesJob.set(wait: 2.minutes).perform_later id
    end
  end
end

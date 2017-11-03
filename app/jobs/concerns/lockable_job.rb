module LockableJob
  extend ActiveSupport::Concern

  def self.prepended(mod)
    mod.class_eval do
      before_enqueue do |job|
        job.arguments << { lock_info: job_subject(job).lock }
      end

      before_perform do |job|
        job.arguments << { lock_info: job_subject(job).lock } unless lock_info?(job.arguments)
      end

      after_perform do |job|
        job_subject(job).try :unlock, job.arguments.last[:lock_info]
      end
    end
  end

  def perform(*args)
    args.pop if lock_info?(args) # Run the job with only the original arguments
    super(*args)
  end

  # Default behavior assumes the first argument of the extended job is an actual object that includes ExtraLockable
  def job_subject(job)
    if defined?(super)
      super
    else
      job.arguments.first
    end
  end

  private

    def lock_info?(args)
      args.last.is_a?(Hash) && args.last.key?(:lock_info)
    end
end

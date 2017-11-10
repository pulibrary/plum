require "rails_helper"

class EnqueuedTestJob < ActiveJob::Base
  def perform(*args)
    args
  end
end

RSpec.describe EnqueuedTestJob do
  it "matches with enqueued job" do
    # The :test adapter is required for these matchers
    ActiveJob::Base.queue_adapter = :test
    expect {
      described_class.perform_later
    }.to have_enqueued_job(described_class)

    expect {
      described_class.perform_later("work", "structure")
    }.to have_enqueued_job.with("work", "structure")

    # Set the adapter back to :inline for subsequent tests
    ActiveJob::Base.queue_adapter = :inline
  end
end

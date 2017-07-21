module IuDevOps
  # Performs a Sidekiq process health check. Uses the same method as the Sidekiq dashboard to discover processes.
  include OkComputer
  class SidekiqProcessCheck < Check
    # Public: Return the status of the Sidekiq processes
    def check
      if running?
        mark_message "Sidekiq is up"
      else
        mark_failure
        mark_message "No Sidekiq processes found"
      end
    end

    def running?
      Sidekiq::ProcessSet.new.size > 0
    end
  end
end

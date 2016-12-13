# IngestCounter forces persistent HTTP connections to periodically
# close to allow backend systems a chance to garbage collect.
class IngestCounter
  attr_reader :count, :limit

  def initialize(n = 100)
    reset
    @limit = n
  end

  def increment
    @count += 1
    pause_http if @count >= @limit
    @count
  end

  def reset
    @count = 0
  end

  def pause_http
    Net::HTTP::Persistent.new('Faraday').shutdown
    reset
  end
end

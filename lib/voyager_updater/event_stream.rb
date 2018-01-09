# frozen_string_literal: true
module VoyagerUpdater
  class EventStream
    attr_reader :url
    def initialize(url)
      @url = url
    end

    def events
      @events ||= parsed_json.map do |json_record|
        Event.new(json_record)
      end
    end

    def process!
      events.each(&:process!)
    end

    private

      def parsed_json
        @parsed_json ||= JSON.parse(open(url).read)
      end
  end
end

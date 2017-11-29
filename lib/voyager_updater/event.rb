# frozen_string_literal: true
module VoyagerUpdater
  class Event
    attr_reader :id, :dump_url, :dump_type
    delegate :ids_needing_updated, to: :dump
    def initialize(init_hsh)
      @id = init_hsh["id"].to_i
      @dump_url = init_hsh["dump_url"]
      @dump_type = init_hsh["dump_type"]
    end

    def processed?
      ProcessedEvent.where(event_id: id).count > 0
    end

    def dump
      @dump ||= Dump.new(dump_url)
    end

    def unprocessable?
      dump_type != "CHANGED_RECORDS"
    end

    def process!
      return if processed? || unprocessable?
      Processor.new(ids_needing_updated).run!
      ProcessedEvent.create!(event_id: id)
    end
  end
end

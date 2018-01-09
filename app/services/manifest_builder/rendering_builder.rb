# frozen_string_literal: true
class ManifestBuilder
  class RenderingBuilder
    attr_reader :record
    def initialize(record)
      @record = record
    end

    def apply(manifest)
      manifest["rendering"] = rendering_hash if identifier?
      manifest
    end

    private

      def identifier?
        record.identifier.present?
      end

      def identifier
        Array.wrap(record.identifier).first
      end

      def rendering_hash
        {
          "@id" => "http://arks.princeton.edu/#{identifier}",
          "format" => "text/html"
        }
      end
  end
end

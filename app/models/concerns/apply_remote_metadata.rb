module ApplyRemoteMetadata
  extend ActiveSupport::Concern

  included do
    validate :source_metadata_identifier_or_title

    def apply_remote_metadata
      if remote_data.source
        self.source_metadata = remote_data.source.dup.try(:force_encoding, 'utf-8')
      end
      if remote_data.respond_to?(:jsonld)
        self.source_jsonld = remote_data.jsonld.dup.try(:force_encoding, 'utf-8')
      end
      self.attributes = enumerable_to_single_valued_attributes(remote_data.attributes)
      CompleteRecord.new(self).complete if workflow_state == 'complete' && identifier.present?
    end

    private

      def enumerable_to_single_valued_attributes(attributes)
        attributes.merge(attributes) do |key, value|
          next unless value
          single_valued_attributes.include?(key) ? value.first : value
        end
      end

      def single_valued_attributes
        attributes.map { |key, value| key unless value.is_a? Enumerable }.compact
      end

      def remote_data
        @remote_data ||= remote_metadata_factory.retrieve(source_metadata_identifier)
      end

      def remote_metadata_factory
        if RemoteRecord.bibdata?(source_metadata_identifier) == 0
          JSONLDRecord::Factory.new(self.class)
        else
          RemoteRecord
        end
      end

      # Validate that either the source_metadata_identifier or the title is set.
      def source_metadata_identifier_or_title
        return if source_metadata_identifier.present? || title.present?
        errors.add(:title, "You must provide a source metadata id or a title")
        errors.add(:source_metadata_identifier, "You must provide a source metadata id or a title")
      end
  end
end

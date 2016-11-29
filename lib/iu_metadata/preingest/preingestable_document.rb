# Include for Preingest models.
# Methods assume that including model provides:
#
#   * #source_file
#   * #multi_volume?
#   * #collections
#
module IuMetadata
  module Preingest
    module PreingestableDocument
      DEFAULT_ATTRIBUTES = {
        state: 'final_review',
        viewing_direction: 'left-to-right',
        rights_statement: 'http://rightsstatements.org/vocab/NKC/1.0/',
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      }

      def yaml_file
        source_file.sub(/\..{3,4}$/, '.yml')
      end

      def source_uri
        URI.join('file://', source_file).to_s
      end

      def attributes
        attribute_sources.map { |k, v| [k, v.raw_attributes] }.to_h
      end

      def attribute_sources
        { default: default_data,
          local: local_data,
          remote: remote_data
        }
      end

      def default_attributes
        DEFAULT_ATTRIBUTES
      end

      def default_id
        local_id
      end

      def local_attributes
        return {} unless local&.attributes
        local.attributes
      end

      def local_id
        URI.join('file://', source_file).to_s
      end

      # typically override in an includer
      def local
        nil
      end

      def source_metadata
        return unless remote_data.source
        remote_data.source.dup.try(:force_encoding, 'utf-8')
      end

      def resource_class
        @resource_class ||= multi_volume? ? MultiVolumeWork : ScannedResource
      end

      private

        def remote_data
          @remote_data ||= remote_metadata_factory.retrieve(source_metadata_identifier)
        end

        def remote_metadata_factory
          if RemoteRecord.bibdata?(source_metadata_identifier)
            JSONLDRecord::Factory.new(resource_class)
          else
            RemoteRecord::Null
          end
        end

        def local_data
          @local_data ||= IuMetadata::AttributeIngester.new(local_id, local_attributes, factory: resource_class)
        end

        def default_data
          @default_data ||= IuMetadata::AttributeIngester.new(default_id, default_attributes, factory: resource_class)
        end
    end
  end
end

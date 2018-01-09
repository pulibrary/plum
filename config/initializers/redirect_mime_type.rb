# frozen_string_literal: true
ActiveFedora::WithMetadata::DefaultMetadataClassFactory.file_metadata_schemas +=
  [
    NewMimeTypeSchema
  ]
Hydra::Works::Characterization.mapper = Hydra::Works::Characterization.mapper.merge(file_mime_type: :mime_type_storage)

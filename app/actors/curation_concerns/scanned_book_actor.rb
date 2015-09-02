# Generated via
#  `rails generate curation_concerns:work ScannedBook`
module CurationConcerns
  class ScannedBookActor < CurationConcerns::BaseActor
    include ::CurationConcerns::WorkActorBehavior

    def create
      was_successful = super
      update_metadata if was_successful
      return was_successful
    end

    def update(options={})
      was_successful = super()
      if was_successful && options.fetch(:refresh_metadata, false)
        update_metadata
      end
      return was_successful
    end

    def update_metadata
      curation_concern.apply_external_metadata
    end

  end
end

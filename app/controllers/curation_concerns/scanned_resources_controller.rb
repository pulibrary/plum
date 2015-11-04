# Generated via
#  `rails generate curation_concerns:work ScannedResource`

class CurationConcerns::ScannedResourcesController < CurationConcerns::CurationConcernsController
  include CurationConcerns::ParentContainer
  set_curation_concern_type ScannedResource
  skip_load_and_authorize_resource only: SearchBuilder.show_actions

  def create
    super

    return unless parent_id
    parent = ActiveFedora::Base.find(parent_id, cast: true)
    parent.ordered_members << curation_concern.reload
    parent.save
    curation_concern.update_index
  end

  def show_presenter
    ScannedResourceShowPresenter
  end

  def pdf
    actor.generate_pdf
    redirect_to main_app.download_path(curation_concern, file: 'pdf')
  end

  def reorder
    @members = presenter.file_presenters
  end

  def save_order
    lock_manager.lock(curation_concern.id) do
      form = ReorderForm.new(curation_concern)
      form.order = params[:order]
      if form.save
        render json: { message: "Succesfully updated order." }
      else
        render json: { message: form.errors.full_messages.to_sentence }, status: :bad_request
      end
    end
  end

  private

    def lock_manager
      @lock_manager ||= CurationConcerns::LockManager.new(
        CurationConcerns.config.lock_time_to_live,
        CurationConcerns.config.lock_retry_count,
        CurationConcerns.config.lock_retry_delay)
    end
end

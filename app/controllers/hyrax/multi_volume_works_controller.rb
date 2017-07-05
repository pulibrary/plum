# Generated via
#  `rails generate hyrax:work MultiVolumeWork`
class Hyrax::MultiVolumeWorksController < Hyrax::HyraxController
  include Hyrax::RemoteMetadata
  self.curation_concern_type = MultiVolumeWork
  skip_load_and_authorize_resource only: SearchBuilder.show_actions

  # copied from Hyrax::CurationConcernController because visibility_changed? was not
  # working when update was inherited
  def update
    if actor.update(attributes_for_actor)
      after_update_response
    else
      respond_to do |wants|
        wants.html do
          build_form
          render 'edit', status: :unprocessable_entity
        end
        wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: curation_concern.errors }) }
      end
    end
  end

  def actor
    @actor ||= Hyrax::CurationConcern.actor(curation_concern, current_ability)
  end

  def build_form
    @form = work_form_service.build(curation_concern, current_ability, self)
  end

  def after_update_response
    if curation_concern.members.present? && curation_concern.visibility_changed?
      return redirect_to main_app.visibility_hyrax_confirm_path(curation_concern)
    end
    super
  end

  def show_presenter
    MultiVolumeWorkShowPresenter
  end
end

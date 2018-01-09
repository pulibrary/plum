# frozen_string_literal: true
# see Hyrax::PermissionsControllerBehavior
class Hyrax::ConfirmController < ApplicationController
  helper_method :curation_concern

  def state
    # intentional noop to display default view
  end

  def copy_state
    authorize! :edit, curation_concern
    CopyStateJob.perform_later(curation_concern)
    flash_message = 'Updating state of attached volumes. This may take a few minutes.'
    redirect_to [main_app, curation_concern], notice: flash_message
  end

  def visibility
    # intentional noop to display default view
  end

  def copy_visibility
    authorize! :edit, curation_concern
    CopyVisibilityJob.perform_later(curation_concern)
    flash_message = 'Updating visibility of attached volumes. This may take a few minutes.'
    redirect_to [main_app, curation_concern], notice: flash_message
  end

  def curation_concern
    @curation_concern ||= ActiveFedora::Base.find(params[:id])
  end
end

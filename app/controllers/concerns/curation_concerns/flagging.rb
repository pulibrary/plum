module CurationConcerns
  module Flagging
    extend ActiveSupport::Concern

    included do
      def flag
        curation_concern.state = 'flagged'
        note = params[curation_concern.class.name.underscore][:workflow_note]
        curation_concern.workflow_note = curation_concern.workflow_note + [note] unless note.blank?
        if curation_concern.save
          respond_to do |format|
            format.html { redirect_to [main_app, curation_concern], notice: "Resource updated" }
            format.json { render json: { state: state } }
          end
        else
          respond_to do |format|
            format.html { redirect_to [main_app, curation_concern], alert: "Unable to update resource" }
            format.json { render json: { error: "Unable to update resource" } }
          end
        end
      end
    end
  end
end

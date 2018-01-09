# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::WorkflowActionsController do
  let(:user) { FactoryGirl.create :admin }
  let(:form) { instance_double(Hyrax::Forms::WorkflowActionForm) }
  let(:mvw) { FactoryGirl.create(:multi_volume_work_with_volume) }

  before do
    sign_in user
    allow(Hyrax::Forms::WorkflowActionForm).to receive(:new).and_return(form)
  end

  describe '#update' do
    context "when the work has members" do
      before do
        allow(form).to receive(:save).and_return(true)
      end

      it "asks to copy state change to members" do
        post :update, params: { id: mvw.id, workflow_action: { name: :metadata_review } }
        expect(response).to redirect_to "http://test.host/concern/confirm/#{mvw.id}/state?locale=en"
      end
    end

    context "when there is an error saving" do
      before do
        allow(form).to receive(:save).and_return(false)
      end

      it "asks to copy state change to members" do
        post :update, params: { id: mvw.id, workflow_action: { name: :metadata_review } }
        expect(response.status).to eq(401)
      end
    end
  end
end

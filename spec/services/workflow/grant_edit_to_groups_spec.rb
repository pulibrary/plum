# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Workflow::GrantEditToGroups do
  let(:depositor) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:scanned_resource, depositor: depositor.user_key) }
  let(:user) { User.new }

  describe '.call' do
    subject do
      described_class.call(target: work)
    end

    it 'adds edit access to groups' do
      expect { subject }.to change { work.edit_groups }.from([]).to(['admin', 'image_editor', 'editor'])
      expect(work).to be_valid
    end
  end
end

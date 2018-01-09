# frozen_string_literal: true
RSpec.configure do |config|
  config.before do
    Hyrax::Workflow::WorkflowImporter.load_workflows
  end
  config.before(:each, admin_set: true) do
    Sipity::Role.find_or_create_by(name: 'depositing')
    AdminSet.find_or_create_default_admin_set_id
  end
end

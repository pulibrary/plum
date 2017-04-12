RSpec.configure do |config|
  config.before(:each) do
    Hyrax::Workflow::WorkflowImporter.load_workflows
  end
  config.before(:each, admin_set: true) do
    AdminSet.find_or_create_default_admin_set_id
  end
end

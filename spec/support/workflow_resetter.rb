RSpec.configure do |config|
  config.before(:each) do
    Hyrax::Workflow::WorkflowImporter.load_workflows
    AdminSet.find_or_create_default_admin_set_id
  end
end

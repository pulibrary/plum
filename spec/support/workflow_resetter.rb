RSpec.configure do |config|
  config.before(:each) do
    Hyrax::DefaultAdminSetActor.new(nil, nil, nil).send(:create_default_admin_set)
    Hyrax::Workflow::WorkflowImporter.load_workflows
  end
end

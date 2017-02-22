RSpec.configure do |config|
  config.before(:each) do
    Hyrax::Workflow::WorkflowImporter.new(data: JSON.parse(File.read(Rails.root.join("config", "workflows", "books_workflow.json")))).call
    Hyrax::Workflow::WorkflowImporter.new(data: JSON.parse(File.read(Rails.root.join("config", "workflows", "geo_workflow.json")))).call
  end
end

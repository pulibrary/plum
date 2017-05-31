class RemoveWorkflowNameFromPermissionTemplates < ActiveRecord::Migration[5.0]
  def change
    remove_column :permission_templates, :workflow_name, :string
  end
end

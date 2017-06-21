class AddTemplateLabelToTemplates < ActiveRecord::Migration[5.0]
  def change
    add_column :templates, :template_label, :string
  end
end

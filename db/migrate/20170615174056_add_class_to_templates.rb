class AddClassToTemplates < ActiveRecord::Migration[5.0]
  def change
    add_column :templates, :template_class, :string
  end
end

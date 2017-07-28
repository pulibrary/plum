class AddLabelToAuthToken < ActiveRecord::Migration[5.0]
  def change
    add_column :auth_tokens, :label, :string
  end
end

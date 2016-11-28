class AddUserAuthorizedMembership < ActiveRecord::Migration
  def change
    add_column :users, :authorized_membership, :boolean
    add_column :users, :authorized_membership_updated_at, :datetime
  end
end

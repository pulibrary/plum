# frozen_string_literal: true
desc "Add admin role to last user"
task add_admin_role: :environment do
  u = User.last
  puts "Adding admin role to user #{u}"
  u.roles << Role.first_or_create(name: 'admin') unless u.admin?
end

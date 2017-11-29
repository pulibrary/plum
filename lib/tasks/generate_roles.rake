# frozen_string_literal: true
desc "Generate default Plum roles"
task generate_roles: :environment do
  ['admin', 'image_editor'].each do |role|
    puts "Generating role #{role}"
    Role.where(name: role).first_or_create
  end
  StateWorkflow.new(nil).aasm.states.each do |state|
    puts "Generating role notify_#{state.name}"
    Role.where(name: "notify_#{state.name}").first_or_create
  end
end

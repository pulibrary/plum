desc "Generate default Plum roles"
task generate_roles: :environment do
  ['admin', 'curation_concern_creator'].each do |role|
    puts "Generating role #{role}"
    Role.where(name: role).first_or_create
  end
end

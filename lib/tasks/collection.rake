namespace :collection do
  desc "Mark all members of a Collection complete"
  task complete: :environment do
    colid = ENV['COLLECTION']
    userid = ENV['USER']
    abort "usage: COLLECTION=[collection id] USER=[userid] rake collection:complete" unless colid && userid
    begin
      col = Collection.find( colid )
      user = User.where(username: userid).first!
      puts "completing objects in collection: #{col.title.first}"
      col.member_objects.each do |obj|
        entity = PowerConverter.convert_to_sipity_entity(obj)
        advance(obj, 'metadata_review', user) if entity.workflow_state.name == 'pending'
        advance(obj, 'final_review', user) if entity.workflow_state.reload.name == 'metadata_review'
        advance(obj, 'complete', user) if entity.reload.workflow_state.reload.name == 'final_review'
      end
    rescue => e
      puts "Error: #{e.message}"
    end
  end

  desc "Copy all members of a Collection to another Collection"
  task copy: :environment do
    begin
      Rails.logger = Logger.new(STDOUT)
      from_collection = Collection.find(ENV['FROM_COLLECTION'])
      to_collection = Collection.find(ENV['TO_COLLECTION'])
      MembershipService.copy_membership(from_collection, to_collection)
    rescue => e
      puts "Error: #{e.message}"
    end
  end

  desc "Transfer all members of a Collection to another Collection"
  task transfer: :environment do
    begin
      Rails.logger = Logger.new(STDOUT)
      from_collection = Collection.find(ENV['FROM_COLLECTION'])
      to_collection = Collection.find(ENV['TO_COLLECTION'])
      MembershipService.transfer_membership(from_collection, to_collection)
    rescue => e
      puts "Error: #{e.message}"
    end
  end
end

def advance(obj, state, user)
  entity = PowerConverter.convert_to_sipity_entity(obj)
  puts "#{obj.id}: #{entity.workflow_state.name} -> #{state}"
  Hyrax::Forms::WorkflowActionForm.new(current_ability: Ability.new(user), work: obj, attributes: { name: state}).save
  manifest_event_generator.record_updated(obj)
end

def manifest_event_generator
  @manifest_event_generator ||= ManifestEventGenerator.new(Plum.messaging_client)
end

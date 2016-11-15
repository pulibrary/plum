desc "Mark all members of a Collection complete"
task complete_collection: :environment do
  colid = ENV['COLLECTION']
  abort "usage: COLLECTION=[collection id] rake complete_collection" unless colid
  begin
    col = Collection.find( colid )
    puts "completing objects in collection: #{col.title.first}"
    col.member_objects.each do |obj|
      advance(obj, 'metadata_review') if obj.state == 'pending'
      advance(obj, 'final_review') if obj.state == 'metadata_review'
      advance(obj, 'complete') if obj.state == 'final_review'
    end
  rescue => e
    puts "Error: #{e.message}"
  end
end

def advance(obj, state)
  puts "#{obj.id}: #{obj.state} -> #{state}"
  obj.state = state
  obj.save!
end

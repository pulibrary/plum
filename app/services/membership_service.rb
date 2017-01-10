module MembershipService
  def self.copy_membership(from_collection, to_collection)
    from_collection.member_objects.each do |obj|
      obj.member_of_collections << to_collection
      obj.save!
      Rails.logger.info "Copied object #{obj.id} to collection #{to_collection.id}"
    end
  end

  def self.transfer_membership(from_collection, to_collection)
    from_collection.member_objects.each do |obj|
      obj.member_of_collections.delete from_collection
      obj.member_of_collections << to_collection
      obj.save!
      Rails.logger.info "Moved object #{obj.id} to collection #{to_collection.id}"
    end
  end
end

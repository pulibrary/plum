# Generated via
#  `rails generate hyrax:work EphemeraFolder`
class EphemeraFolder < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata
  include ::StateBehavior
  apply_schema EphemeraSchema, ActiveFedora::SchemaIndexingStrategy.new(
    ActiveFedora::Indexers::GlobalIndexer.new([:symbol, :stored_searchable, :facetable])
  )
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :identifier, with: :barcode_valid?

  self.human_readable_type = 'Ephemera Folder'

  def barcode_valid?
    return true if Barcode.new(identifier.first).valid?
    errors.add(:identifier, "has an invalid checkdigit")
  end

  def box_id
    box.try(:id)
  end

  def box
    member_of_collections.to_a.find do |coll|
      coll.is_a?(EphemeraBox)
    end
  end
end

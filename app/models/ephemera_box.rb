# Generated via
#  `rails generate hyrax:work EphemeraBox`
class EphemeraBox < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata
  include ::StateBehavior
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [EphemeraFolder]
  validates :title, presence: { message: 'Your work must have a title.' }
  validates :box_number, :identifier, presence: true
  validates :identifier, with: :barcode_valid?
  property :box_number, predicate: ::RDF::RDFS.label

  self.human_readable_type = 'Ephemera Box'
  def box_number=(title)
    super.tap do |box_number|
      self.title = ["Box Number #{box_number.first}"]
    end
  end

  def barcode_valid?
    return true if Barcode.new(identifier.first).valid?
    errors.add(:identifier, "has an invalid checkdigit")
  end
end

require 'rails_helper'

RSpec.describe GenericFile do
  subject { described_class.new.tap { |x| x.apply_depositor_metadata("bob") } }

  describe "#viewing_hint" do
    it "has the right predicate" do
      expect(described_class.properties["viewing_hint"].predicate).to eq ::RDF::Vocab::IIIF.viewingHint
    end
  end
end

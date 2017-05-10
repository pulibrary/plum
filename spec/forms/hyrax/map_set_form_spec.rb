require 'rails_helper'

RSpec.describe Hyrax::MapSetForm do
  let(:work) { FactoryGirl.build(:map_set) }
  let(:form) { described_class.new(work, nil, nil) }

  describe '#primary_terms' do
    it 'has primary terms' do
      expect(form.primary_terms).to include(:portion_note, :nav_date)
    end
  end

  describe '#secondary_terms' do
    it 'has secondary terms' do
      expect(form.secondary_terms).to include(:cartographic_scale, :alternative, :edition)
    end
  end
end

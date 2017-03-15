require 'rails_helper'

RSpec.describe Discovery::GeoblacklightDocument do
  subject { described_class.new }
  describe '#references' do
    it 'adds a iiif reference to the geoblacklight document' do
      expect(subject.references).to have_key('http://iiif.io/api/image')
    end
  end
end

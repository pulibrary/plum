require 'spec_helper'

describe IuMetadata::MarcRecord do
  let(:fixture_path) { File.expand_path('../../fixtures', __FILE__) }
  let(:record1) {
    pth = File.join(fixture_path, '1160682.mrx')
    described_class.new(pth, File.open(pth).read)
  }
  let(:record2) {
    pth = File.join(fixture_path, '7214786.mrx')
    described_class.new(pth, File.open(pth).read)
  }
  let(:record3) {
    pth = File.join(fixture_path, '345682.mrx')
    described_class.new(pth, File.open(pth).read)
  }

  describe 'id' do
    it 'stores its id' do
      expected = File.join(fixture_path, '1160682.mrx')
      expect(record1.id).to eq expected
    end
  end

  describe '#formatted_fields_as_array' do
    it 'gets what you ask for with one' do
      expected = ['The weeping angels']
      expect(record1.formatted_fields_as_array('245')).to eq expected
    end
    it 'gets what you ask for with multiple' do
      fields = ['240', '245', '246']
      expected = [
        'Angels take Manhattan',
        'The weeping angels',
        'Flesh and stone'
      ]
      expect(record1.formatted_fields_as_array(fields)).to eq expected
    end
    it 'respects the separator option' do
      fields = ['650']
      expected = ['International relations.', 'World politics--1985-1995.']
      expect(record3.formatted_fields_as_array(fields, separator: '--')).to eq expected
    end
    it 'respects the codes option' do
      fields = ['650']
      expected = ['International relations.', 'World politics']
      expect(record3.formatted_fields_as_array(fields, codes: ['a'])).to eq expected
    end
  end

  describe '#attributes' do
    it 'works' do
      expected = {
        title: ['The weeping angels'],
        sort_title: 'weeping angels',
        creator: ['Moffat, Steven.'],
        date_created: '1899',
        publisher: ['A. Martínez,']
      }
      expect(record1.attributes).to eq expected
    end
  end

  describe '#alternative_titles' do
    it 'gets the other titles' do
      expected = [
        'Angels take Manhattan',
        'Flesh and stone'
      ]
      expect(record1.alternative_titles).to eq expected
    end
  end

  describe '#creator' do
    it 'gets it from the 100' do
      expect(record1.creator).to eq ['Moffat, Steven.']
    end
    it 'includes the 880 version if there is one' do
      expect(record2.creator).to eq ['Pesin, Aharon Yehoshuʻa.', 'פסין, אהרן יהושע.']
    end
  end

  describe '#date' do
    it 'seems to work (there are infinite possibilities)' do
      expect(record1.date).to eq '1899'
      expect(record2.date).to eq '2012'
    end
  end

  describe '#parts' do
    it 'retrieves 7xxs with ts' do
      expect(record3.parts).to eq ["Jones, Martha. The doctor's daughter."]
    end
  end

  describe '#language_codes' do
    it 'gets them' do
      expect(record1.language_codes).to eq ['spa']
      expect(record2.language_codes).to eq ['heb']
    end
    it "handles 'mul'" do
      expect(record3.language_codes).to eq ['eng', 'dut']
    end
  end

  describe '#sort_title' do
    it 'gets it' do
      expect(record1.sort_title).to eq 'weeping angels'
    end
  end

  describe '#title' do
    it 'gets it' do
      expect(record1.title).to eq ['The weeping angels']
      expect(record2.title).to eq ['Be-darkhe avot', 'בדרכי אבות']
    end
  end

  describe '#contents' do
    it 'gets the 505s as one squashed string' do
      expect(record1.contents).to eq 'Contents / foo.'
    end
  end
end

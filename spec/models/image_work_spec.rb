require 'rails_helper'

describe ImageWork do
  let(:image_work) { FactoryGirl.build(:image_work, rights_statement: ['http://rightsstatements.org/vocab/NKC/1.0/']) }
  subject { image_work }

  describe 'apply_remote_metadata' do
    context 'when source_metadata_identifier is not set' do
      before { subject.source_metadata_identifier = nil }
      it 'does nothing' do
        original_attributes = subject.attributes
        expect(subject.send(:remote_metadata_factory)).to_not receive(:new)
        subject.apply_remote_metadata
        expect(subject.attributes).to eq(original_attributes)
      end
    end

    context 'With a Voyager ID', vcr: { cassette_name: "bibdata-maps" } do
      before do
        subject.source_metadata_identifier = ['9284317']
      end

      it 'Extracts Voyager Metadata' do
        subject.apply_remote_metadata
        expect(subject.title.first.to_s).to eq('Netherlands, Nieuwe Waterweg and Europoort : Hoek Van Holland to Vlaardingen')
        expect(subject.resource.get_values(:title, literal: true)).to eq([RDF::Literal.new('Netherlands, Nieuwe Waterweg and Europoort : Hoek Van Holland to Vlaardingen', language: :eng)])
        expect(subject.creator).to eq(['United States. Defense Mapping Agency. Hydrographic/Topographic Center'])
        expect(subject.date_created).to eq(['1994-01-01T00:00:00Z'])
        expect(subject.publisher).to eq(['Bethesda, Md. : Defense Mapping Agency, Hydrographic/Topographic Center, 1994.'])
        expect(subject.coverage).to eq('northlimit=52.024167; eastlimit=004.341667; southlimit=51.920000; westlimit=003.966667; units=degrees; projection=EPSG:4326')
      end

      it 'Saves a record with extacted Voyager metadata' do
        subject.apply_remote_metadata
        subject.save
        expect { subject.save }.to_not raise_error
        expect(subject.id).to be_truthy
      end
    end
  end
end

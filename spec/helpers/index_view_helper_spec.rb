require 'rails_helper'

describe IndexViewHelper do
  subject { helper }
  let(:document) { instance_double(SolrDocument, subject: subject_list) }
  let(:args) { { document: document } }

  describe '#index_subject' do
    context 'with a long list of subject terms' do
      let(:subject_list) { ['1', '2', '3', '4', '5', '6', '7', '8', '9'] }
      it 'returns a list with a maximum of 7 items' do
        expect(subject.index_subject(args)).to eq '1<br/>2<br/>3<br/>4<br/>5<br/>6<br/>7'
      end
    end
  end
end

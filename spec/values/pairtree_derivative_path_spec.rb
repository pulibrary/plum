require 'rails_helper'

describe PairtreeDerivativePath do
  before do
    allow(CurationConcerns.config).to receive(:derivatives_path).and_return('tmp')
  end

  describe '.derivative_path_for_reference' do
    subject { described_class.derivative_path_for_reference(object, destination_name) }

    let(:object) { double(id: '08612n57q') }
    let(:destination_name) { 'thumbnail' }

    it { is_expected.to eq 'tmp/08/61/2n/57/q-thumbnail.jpeg' }
    context "when given an intermediate file" do
      let(:destination_name) { 'intermediate_file' }

      it { is_expected.to eq 'tmp/08/61/2n/57/q-intermediate_file.jp2' }
    end
  end
end

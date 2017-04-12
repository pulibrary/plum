require 'rails_helper'

RSpec.describe PersistPairtreeDerivatives do
  describe '#derivative_path_factory' do
    it 'is a PairtreeDerivativePath' do
      expect(described_class.derivative_path_factory).to be(PairtreeDerivativePath)
    end
  end
end

require 'rails_helper'

RSpec.describe Hyrax::Actors::MapSetActor do
  it 'is a BaseActor' do
    expect(described_class < ::Hyrax::Actors::BaseActor).to be true
  end
end

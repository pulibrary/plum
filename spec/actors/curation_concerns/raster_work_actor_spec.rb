# Generated via
#  `rails generate geo_concerns:install`
require 'rails_helper'

describe Hyrax::Actors::RasterWorkActor do
  it 'is a BaseActor' do
    expect(described_class < ::Hyrax::Actors::BaseActor).to be true
  end
end

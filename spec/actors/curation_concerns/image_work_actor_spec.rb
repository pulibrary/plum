# Generated via
#  `rails generate geo_concerns:install`
require 'rails_helper'

describe CurationConcerns::Actors::ImageWorkActor do
  it 'is a BaseActor' do
    expect(described_class < ::CurationConcerns::Actors::BaseActor).to be true
  end
end

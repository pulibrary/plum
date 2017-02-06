# Generated via
#  `rails generate curation_concerns:work ScannedResource`
require 'rails_helper'

describe Hyrax::Actors::ScannedResourceActor do
  let(:user) { FactoryGirl.create(:user) }
  let(:scanned_resource) { FactoryGirl.build(:scanned_resource, id: 'fakeID') }
  let(:attributes) { {} }
  let(:actor) do
    described_class.new(scanned_resource, user, attributes)
  end
  subject { actor }

  it 'is a BaseActor' do
    expect(described_class < ::Hyrax::Actors::BaseActor).to be true
  end
end

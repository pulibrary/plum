# Generated via
#  `rails generate curation_concerns:work ScannedBook`
require 'rails_helper'

describe CurationConcerns::ScannedBookActor do
  it 'behaves like a GenericWorkActor' do
    expect(described_class.included_modules).to include(::CurationConcerns::WorkActorBehavior)
  end
end

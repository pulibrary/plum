# Generated via
#  `rails generate curation_concerns:work ScannedResource`
require 'rails_helper'

describe CurationConcerns::ScannedResourceActor do
  let(:user) { FactoryGirl.create(:user) }
  let(:scanned_resource) { FactoryGirl.build(:scanned_resource, id: 'fakeID') }
  let(:attributes) { {} }
  let(:actor) do
    described_class.new(scanned_resource, user, attributes)
  end
  subject { actor }

  it 'behaves like a GenericWorkActor' do
    expect(described_class.included_modules).to include(::CurationConcerns::WorkActorBehavior)
  end

  describe '#generate_pdf' do
    it 'persists the pdf to the default local derivative path' do
      derivative_path = CurationConcerns::DerivativePath.derivative_path_for_reference(scanned_resource, 'pdf')
      expect(scanned_resource).to receive(:render_pdf).with(derivative_path)
      subject.generate_pdf
    end
  end
end

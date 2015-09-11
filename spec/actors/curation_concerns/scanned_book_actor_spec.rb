# Generated via
#  `rails generate curation_concerns:work ScannedBook`
require 'rails_helper'

describe CurationConcerns::ScannedBookActor do
  let(:user) { FactoryGirl.create(:user) }
  let(:scanned_book) { FactoryGirl.build(:scanned_book, id: 'fakeID') }
  let(:attributes) { {} }
  let(:actor) do
    described_class.new(scanned_book, user, attributes)
  end
  subject { actor }

  it 'behaves like a GenericWorkActor' do
    expect(described_class.included_modules).to include(::CurationConcerns::WorkActorBehavior)
  end

  describe '#generate_pdf' do
    it 'persists the pdf to the default local derivative path' do
      derivative_path = CurationConcerns::DerivativePath.derivative_path_for_reference(scanned_book, 'pdf')
      expect(scanned_book).to receive(:render_pdf).with(derivative_path)
      subject.generate_pdf
    end
  end
end

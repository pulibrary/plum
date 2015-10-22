require 'rails_helper'

RSpec.describe User, type: :model do
  let(:included_modules) { described_class.included_modules }
  it 'has PulUserRoles functionality' do
    expect(included_modules).to include(::PulUserRoles)
    expect(subject).to respond_to(:campus_patron?)
    expect(subject).to respond_to(:curation_concern_creator?)
  end
  it 'has Hydra Role Management behaviors' do
    expect(included_modules).to include(Hydra::RoleManagement::UserRoles)
    expect(subject).to respond_to(:admin?)
  end
  describe "#authorized?" do
    context "when the user has an authorized role" do
      it "is false" do
        expect(subject).not_to be_authorized
      end
    end
    context "when the user has an authorized role" do
      it "is true" do
        subject.save
        subject.roles << Role.first_or_create(name: "authorized")
        expect(subject).to be_authorized
      end
    end
  end
end

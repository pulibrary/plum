require 'rails_helper'

RSpec.describe User, type: :model do
  let(:included_modules) { described_class.included_modules }
  it 'has IuUserRoles functionality' do
    expect(included_modules).to include(::IuUserRoles)
    expect(included_modules).to include(LDAPGroupsLookup::Behavior)
    expect(subject).to respond_to(:campus_patron?)
    expect(subject).to respond_to(:image_editor?)
    expect(subject).to respond_to(:ldap_lookup_key)
  end
  it 'has Hydra Role Management behaviors' do
    expect(included_modules).to include(Hydra::RoleManagement::UserRoles)
    expect(subject).to respond_to(:admin?)
  end

  describe "#campus_patron?" do
    context "when logged in from CAS" do
      subject do
        described_class.from_omniauth(OpenStruct.new(provider: "cas", uid: "testuser"))
      end
      it "is true" do
        expect(subject).to be_campus_patron
      end
    end
  end
end

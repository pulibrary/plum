require 'rails_helper'

RSpec.describe User, type: :model do
  it "has PulUserRoles functionality" do
    expect(described_class.included_modules).to include(::PulUserRoles)
    expect(subject).to respond_to(:campus_patron?)
    expect(subject).to respond_to(:scanned_book_creator?)
  end
  it "has Hydra Role Management behaviors" do
    expect(described_class.included_modules).to include(Hydra::RoleManagement::UserRoles)
    expect(subject).to respond_to(:admin?)
  end
end

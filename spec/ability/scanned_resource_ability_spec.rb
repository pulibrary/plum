require 'rails_helper'
require "cancan/matchers"

describe Ability do
  subject { described_class.new(current_user) }

  let(:scanned_resource) {
    FactoryGirl.create(:scanned_resource, user: creating_user)
  }

  let(:open_scanned_resource) { scanned_resource }

  let(:campus_only_scanned_resource) {
    FactoryGirl.create(:campus_only_scanned_resource, user: creating_user)
  }

  let(:user) {
    FactoryGirl.create(:user)
  }

  describe 'without embargo' do
    describe 'as a scanned resource creator' do
      let(:creating_user) { user }
      let(:current_user) { FactoryGirl.create(:scanned_resource_creator) }
      it { should be_able_to(:create, ScannedResource.new) }
      it { should be_able_to(:create, FileSet.new) }
      it { should be_able_to(:read, scanned_resource) }
      it { should be_able_to(:pdf, scanned_resource) }
      it { should be_able_to(:update, scanned_resource) }
      it { should_not be_able_to(:destroy, scanned_resource) }
    end

    describe 'as an admin' do
      let(:manager_user) { FactoryGirl.create(:admin) }
      let(:creating_user) { user }
      let(:current_user) { manager_user }
      it { should be_able_to(:create, ScannedResource.new) }
      it { should be_able_to(:create, FileSet.new) }
      it { should be_able_to(:read, scanned_resource) }
      it { should be_able_to(:pdf, scanned_resource) }
      it { should be_able_to(:update, scanned_resource) }
      it { should be_able_to(:destroy, scanned_resource) }
    end

    describe 'as a campus user' do
      let(:creating_user) { FactoryGirl.create(:user) }
      let(:current_user) { user }
      it { should_not be_able_to(:create, ScannedResource.new) }
      it { should_not be_able_to(:create, FileSet.new) }
      it { should be_able_to(:read, campus_only_scanned_resource) }
      it { should be_able_to(:pdf, scanned_resource) }
      it { should_not be_able_to(:update, scanned_resource) }
      it { should_not be_able_to(:destroy, scanned_resource) }
    end

    describe 'a guest user' do
      let(:creating_user) { FactoryGirl.create(:user) }
      let(:current_user) { nil }
      it { should_not be_able_to(:create, ScannedResource.new) }
      it { should_not be_able_to(:create, FileSet.new) }
      it { should_not be_able_to(:read, campus_only_scanned_resource) }
      it { should_not be_able_to(:pdf, campus_only_scanned_resource) }
      it { should_not be_able_to(:update, scanned_resource) }
      it { should_not be_able_to(:destroy, scanned_resource) }
      it { should be_able_to(:read, open_scanned_resource) }
      it { should be_able_to(:pdf, open_scanned_resource) }
    end
  end
end

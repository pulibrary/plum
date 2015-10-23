require 'rails_helper'
require "cancan/matchers"

RSpec.describe Ability do
  subject { described_class.new(user) }
  let(:user) { nil }

  context "when it's an admin" do
    let(:user) { FactoryGirl.create(:admin) }

    describe "role management" do
      it { should be_able_to(:create, Role) }
      it { should be_able_to(:read, Role) }
      it { should be_able_to(:add_user, Role) }
      it { should be_able_to(:remove_user, Role) }
      it { should be_able_to(:index, Role) }
    end

    describe "curation concern management" do
      it { should be_able_to(:manage, ScannedResource) }
      it { should be_able_to(:manage, MultiVolumeWork) }
    end

    describe "file set management" do
      it { should be_able_to(:manage, FileSet) }
    end

    describe "manifest permissions" do
      it { should be_able_to(:manifest, :all) }
    end
  end

  context "when a curation concern creator" do
    let(:user) { FactoryGirl.create(:curation_concern_creator) }
    describe "curation concern management" do
      CurationConcerns.config.curation_concerns.each do |concern|
        it { should be_able_to(:manage, concern) }
      end
    end

    describe "role management" do
      [:create, :read, :add_user, :remove_user, :index, :manage].each do |permission|
        it { should_not be_able_to(permission, Role) }
      end
    end

    describe "file set management" do
      it { should be_able_to(:manage, FileSet) }
    end
  end

  context "when a campus patron" do
    let(:user) { FactoryGirl.create(:campus_patron) }

    describe "curation concern management" do
      CurationConcerns.config.curation_concerns.each do |concern|
        it { should be_able_to(:read, concern) }
        [:create, :update, :manage].each do |permission|
          it "should be able to #{permission}" do
            new_concern = FactoryGirl.build(:scanned_resource)
            # Need an ID to look up groups for update
            new_concern.save if permission == :update
            expect(subject.can?(permission, new_concern)).to eq false
          end
        end
      end
    end
  end
end

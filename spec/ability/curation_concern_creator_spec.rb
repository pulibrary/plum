require 'rails_helper'
require "cancan/matchers"

describe Ability do
  subject { described_class.new(current_user) }

  let(:open_scanned_resource) {
    FactoryGirl.build(:open_scanned_resource, user: creating_user)
  }

  let(:private_scanned_resource) {
    FactoryGirl.build(:private_scanned_resource, user: creating_user)
  }

  let(:campus_only_scanned_resource) {
    FactoryGirl.build(:campus_only_scanned_resource, user: creating_user)
  }

  let(:user) {
    FactoryGirl.create(:user)
  }

  let(:solr) { ActiveFedora.solr.conn }
  before do
    allow(open_scanned_resource).to receive(:id).and_return("open")
    allow(private_scanned_resource).to receive(:id).and_return("private")
    allow(campus_only_scanned_resource).to receive(:id).and_return("campus_only")
    [open_scanned_resource, private_scanned_resource, campus_only_scanned_resource].each do |obj|
      allow(subject.cache).to receive(:get).with(obj.id).and_return(Hydra::PermissionsSolrDocument.new(obj.to_solr, nil))
    end
  end

  describe 'without embargo' do
    describe 'as a scanned resource creator' do
      let(:creating_user) { user }
      let(:current_user) { FactoryGirl.create(:curation_concern_creator) }
      it { should be_able_to(:create, ScannedResource.new) }
      it { should be_able_to(:create, FileSet.new) }
      it { should be_able_to(:read, open_scanned_resource) }
      it { should be_able_to(:pdf, open_scanned_resource) }
      it { should be_able_to(:update, open_scanned_resource) }
      it { should be_able_to(:manifest, open_scanned_resource) }
      it { should_not be_able_to(:destroy, open_scanned_resource) }
    end

    describe 'as an admin' do
      let(:manager_user) { FactoryGirl.create(:admin) }
      let(:creating_user) { user }
      let(:current_user) { manager_user }
      it { should be_able_to(:create, ScannedResource.new) }
      it { should be_able_to(:create, FileSet.new) }
      it { should be_able_to(:read, open_scanned_resource) }
      it { should be_able_to(:pdf, open_scanned_resource) }
      it { should be_able_to(:update, open_scanned_resource) }
      it { should be_able_to(:destroy, open_scanned_resource) }
      it { should be_able_to(:manifest, open_scanned_resource) }
      it { should be_able_to(:read, private_scanned_resource) }
    end

    describe 'as a campus user' do
      let(:creating_user) { FactoryGirl.create(:user) }
      let(:current_user) { user }
      it { should_not be_able_to(:create, ScannedResource.new) }
      it { should_not be_able_to(:create, FileSet.new) }
      it { should be_able_to(:read, campus_only_scanned_resource) }
      it { should be_able_to(:pdf, open_scanned_resource) }
      it { should_not be_able_to(:update, open_scanned_resource) }
      it { should_not be_able_to(:destroy, open_scanned_resource) }
      it { should be_able_to(:manifest, open_scanned_resource) }
      it { should_not be_able_to(:read, private_scanned_resource) }
    end

    describe 'a guest user' do
      let(:creating_user) { FactoryGirl.create(:user) }
      let(:current_user) { nil }
      it { should_not be_able_to(:create, ScannedResource.new) }
      it { should_not be_able_to(:create, FileSet.new) }
      it { should_not be_able_to(:read, campus_only_scanned_resource) }
      it { should_not be_able_to(:manifest, campus_only_scanned_resource) }
      it { should_not be_able_to(:pdf, campus_only_scanned_resource) }
      it { should_not be_able_to(:update, open_scanned_resource) }
      it { should_not be_able_to(:destroy, open_scanned_resource) }
      it { should_not be_able_to(:manifest, private_scanned_resource) }
      it { should_not be_able_to(:read, private_scanned_resource) }
      it { should be_able_to(:read, open_scanned_resource) }
      it { should be_able_to(:pdf, open_scanned_resource) }
      it { should be_able_to(:manifest, open_scanned_resource) }
    end
  end
end

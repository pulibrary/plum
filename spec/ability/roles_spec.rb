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

  let(:pending_scanned_resource) {
    FactoryGirl.build(:scanned_resource, user: creating_user, state: 'pending')
  }

  let(:complete_scanned_resource) {
    FactoryGirl.build(:scanned_resource, user: admin_user, state: 'complete', identifier: 'ark:/99999/fk4445wg45')
  }

  let(:image_editor_file) { FactoryGirl.build(:file_set, user: image_editor) }
  let(:admin_file) { FactoryGirl.build(:file_set, user: admin_user) }

  let(:admin_user) { FactoryGirl.create(:admin) }
  let(:image_editor) { FactoryGirl.create(:image_editor) }
  let(:editor) { FactoryGirl.create(:editor) }
  let(:fulfiller) { FactoryGirl.create(:fulfiller) }
  let(:user) { FactoryGirl.create(:user) }
  let(:role) { Role.where(name: 'admin').first_or_create }
  let(:solr) { ActiveFedora.solr.conn }

  before do
    allow(open_scanned_resource).to receive(:id).and_return("open")
    allow(private_scanned_resource).to receive(:id).and_return("private")
    allow(campus_only_scanned_resource).to receive(:id).and_return("campus_only")
    allow(pending_scanned_resource).to receive(:id).and_return("pending")
    allow(complete_scanned_resource).to receive(:id).and_return("complete")
    allow(image_editor_file).to receive(:id).and_return("image_editor_file")
    allow(admin_file).to receive(:id).and_return("admin_file")
    [open_scanned_resource, private_scanned_resource, campus_only_scanned_resource, pending_scanned_resource, complete_scanned_resource, image_editor_file, admin_file].each do |obj|
      allow(subject.cache).to receive(:get).with(obj.id).and_return(Hydra::PermissionsSolrDocument.new(obj.to_solr, nil))
    end
  end

  describe 'as an admin' do
    let(:admin_user) { FactoryGirl.create(:admin) }
    let(:creating_user) { user }
    let(:current_user) { admin_user }
    let(:open_scanned_resource_presenter) { ScannedResourceShowPresenter.new(open_scanned_resource, subject) }
    it { should be_able_to(:create, ScannedResource.new) }
    it { should be_able_to(:create, FileSet.new) }
    it { should be_able_to(:read, open_scanned_resource) }
    it { should be_able_to(:pdf, open_scanned_resource) }
    it { should be_able_to(:edit, open_scanned_resource) }
    it { should be_able_to(:edit, open_scanned_resource_presenter.id) }
    it { should be_able_to(:update, open_scanned_resource) }
    it { should be_able_to(:destroy, open_scanned_resource) }
    it { should be_able_to(:manifest, open_scanned_resource) }
    it { should be_able_to(:read, private_scanned_resource) }
  end

  describe 'as an image editor' do
    let(:creating_user) { image_editor }
    let(:current_user) { image_editor }
    it { should be_able_to(:read, open_scanned_resource) }
    it { should be_able_to(:manifest, open_scanned_resource) }
    it { should be_able_to(:pdf, open_scanned_resource) }
    it { should be_able_to(:flag, open_scanned_resource) }
    it { should be_able_to(:read, campus_only_scanned_resource) }
    it { should be_able_to(:read, private_scanned_resource) }
    it { should be_able_to(:read, pending_scanned_resource) }
    it { should be_able_to(:download, image_editor_file) }
    it { should be_able_to(:bulk_edit, open_scanned_resource) }
    it { should be_able_to(:save_structure, open_scanned_resource) }
    it { should be_able_to(:update, open_scanned_resource) }
    it { should be_able_to(:create, ScannedResource.new) }
    it { should be_able_to(:create, FileSet.new) }
    it { should be_able_to(:destroy, image_editor_file) }
    it { should be_able_to(:destroy, pending_scanned_resource) }

    it { should_not be_able_to(:destroy, complete_scanned_resource) }
    it { should_not be_able_to(:create, Role.new) }
    it { should_not be_able_to(:destroy, role) }
    it { should_not be_able_to(:complete, pending_scanned_resource) }
    it { should_not be_able_to(:destroy, complete_scanned_resource) }
    it { should_not be_able_to(:destroy, admin_file) }
  end

  describe 'as an editor' do
    let(:creating_user) { image_editor }
    let(:current_user) { editor }
    it { should be_able_to(:read, open_scanned_resource) }
    it { should be_able_to(:manifest, open_scanned_resource) }
    it { should be_able_to(:pdf, open_scanned_resource) }
    it { should be_able_to(:flag, open_scanned_resource) }
    it { should be_able_to(:read, campus_only_scanned_resource) }
    it { should be_able_to(:read, private_scanned_resource) }
    it { should be_able_to(:read, pending_scanned_resource) }
    it { should be_able_to(:bulk_edit, open_scanned_resource) }
    it { should be_able_to(:save_structure, open_scanned_resource) }
    it { should be_able_to(:update, open_scanned_resource) }

    it { should_not be_able_to(:download, image_editor_file) }
    it { should_not be_able_to(:create, ScannedResource.new) }
    it { should_not be_able_to(:create, FileSet.new) }
    it { should_not be_able_to(:destroy, image_editor_file) }
    it { should_not be_able_to(:destroy, pending_scanned_resource) }
    it { should_not be_able_to(:destroy, complete_scanned_resource) }
    it { should_not be_able_to(:create, Role.new) }
    it { should_not be_able_to(:destroy, role) }
    it { should_not be_able_to(:complete, pending_scanned_resource) }
    it { should_not be_able_to(:destroy, complete_scanned_resource) }
    it { should_not be_able_to(:destroy, admin_file) }
  end

  describe 'as a fulfiller' do
    let(:creating_user) { image_editor }
    let(:current_user) { fulfiller }
    it { should be_able_to(:read, open_scanned_resource) }
    it { should be_able_to(:manifest, open_scanned_resource) }
    it { should be_able_to(:pdf, open_scanned_resource) }
    it { should be_able_to(:flag, open_scanned_resource) }
    it { should be_able_to(:read, campus_only_scanned_resource) }
    it { should be_able_to(:read, private_scanned_resource) }
    it { should be_able_to(:read, pending_scanned_resource) }
    it { should be_able_to(:download, image_editor_file) }

    it { should_not be_able_to(:bulk_edit, open_scanned_resource) }
    it { should_not be_able_to(:save_structure, open_scanned_resource) }
    it { should_not be_able_to(:update, open_scanned_resource) }
    it { should_not be_able_to(:create, ScannedResource.new) }
    it { should_not be_able_to(:create, FileSet.new) }
    it { should_not be_able_to(:destroy, image_editor_file) }
    it { should_not be_able_to(:destroy, pending_scanned_resource) }
    it { should_not be_able_to(:destroy, complete_scanned_resource) }
    it { should_not be_able_to(:create, Role.new) }
    it { should_not be_able_to(:destroy, role) }
    it { should_not be_able_to(:complete, pending_scanned_resource) }
    it { should_not be_able_to(:destroy, complete_scanned_resource) }
    it { should_not be_able_to(:destroy, admin_file) }
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

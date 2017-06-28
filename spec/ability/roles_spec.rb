require 'rails_helper'
require "cancan/matchers"

describe Ability do
  subject { described_class.new(current_user) }

  let(:open_multi_volume_work) {
    FactoryGirl.create(:complete_open_multi_volume_work, user: creating_user)
  }

  let(:open_scanned_resource) {
    FactoryGirl.create(:complete_open_scanned_resource, user: creating_user)
  }

  let(:private_scanned_resource) {
    FactoryGirl.create(:complete_private_scanned_resource, user: creating_user)
  }

  let(:campus_only_scanned_resource) {
    FactoryGirl.create(:complete_campus_only_scanned_resource, user: creating_user)
  }

  let(:pending_scanned_resource) {
    FactoryGirl.create(:pending_scanned_resource, user: creating_user)
  }

  let(:metadata_review_scanned_resource) {
    FactoryGirl.create(:metadata_review_scanned_resource, user: creating_user)
  }

  let(:final_review_scanned_resource) {
    FactoryGirl.create(:final_review_scanned_resource, user: creating_user)
  }

  let(:complete_scanned_resource) {
    FactoryGirl.create(:complete_scanned_resource, user: image_editor, identifier: ['ark:/99999/fk4445wg45'])
  }

  let(:takedown_scanned_resource) {
    FactoryGirl.create(:takedown_scanned_resource, user: image_editor, identifier: ['ark:/99999/fk4445wg45'])
  }

  let(:flagged_scanned_resource) {
    FactoryGirl.create(:flagged_scanned_resource, user: image_editor, identifier: ['ark:/99999/fk4445wg45'])
  }

  let(:complete_ephemera_folder) {
    FactoryGirl.create(:complete_ephemera_folder, user: creating_user)
  }

  let(:needs_qa_ephemera_folder) {
    FactoryGirl.create(:needs_qa_ephemera_folder, user: creating_user)
  }

  let(:external_metadata_file) { FactoryGirl.build(:file_set, user: creating_user, geo_mime_type: 'application/xml; schema=fgdc') }
  let(:ephemera_editor_file) { FactoryGirl.build(:file_set, user: ephemera_editor) }
  let(:image_editor_file) { FactoryGirl.build(:file_set, user: image_editor) }
  let(:admin_file) { FactoryGirl.build(:file_set, user: admin_user) }

  let(:admin_user) { FactoryGirl.create(:admin) }
  let(:ephemera_editor) { FactoryGirl.create(:ephemera_editor) }
  let(:image_editor) { FactoryGirl.create(:image_editor) }
  let(:editor) { FactoryGirl.create(:editor) }
  let(:completer) { FactoryGirl.create(:completer) }
  let(:fulfiller) { FactoryGirl.create(:fulfiller) }
  let(:curator) { FactoryGirl.create(:curator) }
  let(:campus_user) { FactoryGirl.create(:user) }
  let(:role) { Role.where(name: 'admin').first_or_create }
  let(:solr) { ActiveFedora.solr.conn }

  def presenter(resource)
    DynamicShowPresenter.new.new(SolrDocument.new(resource.to_solr), subject)
  end

  before do
    allow(open_scanned_resource).to receive(:id).and_return("open")
    allow(private_scanned_resource).to receive(:id).and_return("private")
    allow(campus_only_scanned_resource).to receive(:id).and_return("campus_only")
    allow(pending_scanned_resource).to receive(:id).and_return("pending")
    allow(metadata_review_scanned_resource).to receive(:id).and_return("metadata_review")
    allow(final_review_scanned_resource).to receive(:id).and_return("final_review")
    allow(complete_scanned_resource).to receive(:id).and_return("complete")
    allow(takedown_scanned_resource).to receive(:id).and_return("takedown")
    allow(flagged_scanned_resource).to receive(:id).and_return("flagged")
    allow(external_metadata_file).to receive(:id).and_return("external_metadata_file")
    allow(image_editor_file).to receive(:id).and_return("image_editor_file")
    allow(ephemera_editor_file).to receive(:id).and_return("ephemera_editor_file")
    allow(admin_file).to receive(:id).and_return("admin_file")
    [open_scanned_resource, private_scanned_resource, campus_only_scanned_resource, pending_scanned_resource, metadata_review_scanned_resource, final_review_scanned_resource, complete_scanned_resource, takedown_scanned_resource, flagged_scanned_resource, image_editor_file, ephemera_editor_file, admin_file, complete_ephemera_folder, needs_qa_ephemera_folder].each do |obj|
      allow(subject.cache).to receive(:get).with(obj.id).and_return(Hydra::PermissionsSolrDocument.new(obj.to_solr, nil))
    end
  end

  describe 'as an admin' do
    let(:admin_user) { FactoryGirl.create(:admin) }
    let(:creating_user) { image_editor }
    let(:current_user) { admin_user }
    let(:open_scanned_resource_presenter) { ScannedResourceShowPresenter.new(open_scanned_resource, subject) }

    it {
      should be_able_to(:create, ScannedResource.new)
      should be_able_to(:create, FileSet.new)
      should be_able_to(:read, open_scanned_resource)
      should be_able_to(:read, private_scanned_resource)
      should be_able_to(:read, takedown_scanned_resource)
      should be_able_to(:read, flagged_scanned_resource)
      should be_able_to(:pdf, open_scanned_resource)
      should be_able_to(:color_pdf, open_scanned_resource)
      should be_able_to(:edit, open_scanned_resource)
      should be_able_to(:edit, open_scanned_resource_presenter.id)
      should be_able_to(:edit, private_scanned_resource)
      should be_able_to(:edit, takedown_scanned_resource)
      should be_able_to(:edit, flagged_scanned_resource)
      should be_able_to(:file_manager, open_scanned_resource)
      should be_able_to(:file_manager, open_multi_volume_work)
      should be_able_to(:update, open_scanned_resource)
      should be_able_to(:update, private_scanned_resource)
      should be_able_to(:update, takedown_scanned_resource)
      should be_able_to(:update, flagged_scanned_resource)
      should be_able_to(:destroy, open_scanned_resource)
      should be_able_to(:destroy, private_scanned_resource)
      should be_able_to(:destroy, takedown_scanned_resource)
      should be_able_to(:destroy, flagged_scanned_resource)
      should be_able_to(:manifest, open_scanned_resource)
      should be_able_to(:manifest, pending_scanned_resource)
    }
    it "can create works" do
      expect(subject.can_create_any_work?).to be true
    end
  end

  describe 'as an ephemera editor' do
    let(:creating_user) { image_editor }
    let(:current_user) { ephemera_editor }
    let(:ephemera_folder) { FactoryGirl.create(:ephemera_folder, user: ephemera_editor) }
    let(:other_ephemera_folder) { FactoryGirl.create(:ephemera_folder, user: image_editor) }

    it {
      should be_able_to(:read, open_scanned_resource)
      should be_able_to(:manifest, open_scanned_resource)
      should be_able_to(:pdf, open_scanned_resource)
      should_not be_able_to(:color_pdf, open_scanned_resource)
      should be_able_to(:read, campus_only_scanned_resource)
      should_not be_able_to(:read, private_scanned_resource)
      should_not be_able_to(:read, pending_scanned_resource)
      should_not be_able_to(:read, metadata_review_scanned_resource)
      should_not be_able_to(:read, final_review_scanned_resource)
      should be_able_to(:read, complete_scanned_resource)
      should_not be_able_to(:read, takedown_scanned_resource)
      should be_able_to(:read, flagged_scanned_resource)
      should be_able_to(:download, image_editor_file)
      should_not be_able_to(:file_manager, open_scanned_resource)
      should_not be_able_to(:file_manager, open_multi_volume_work)
      should_not be_able_to(:save_structure, open_scanned_resource)
      should_not be_able_to(:update, open_scanned_resource)
      should_not be_able_to(:create, ScannedResource.new)
      should be_able_to(:create, FileSet.new)
      should_not be_able_to(:destroy, image_editor_file)
      should be_able_to(:destroy, ephemera_editor_file)
      should_not be_able_to(:destroy, pending_scanned_resource)

      should be_able_to(:create, EphemeraBox.new)
      should be_able_to(:create, EphemeraFolder.new)
      should be_able_to(:read, ephemera_folder)
      should be_able_to(:update, ephemera_folder)
      should be_able_to(:destroy, ephemera_folder)
      should be_able_to(:read, other_ephemera_folder)
      should be_able_to(:update, other_ephemera_folder)
      should be_able_to(:destroy, other_ephemera_folder)

      should be_able_to(:manifest, presenter(complete_ephemera_folder))
      should be_able_to(:manifest, presenter(needs_qa_ephemera_folder))

      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
      should_not be_able_to(:complete, pending_scanned_resource)
      should_not be_able_to(:destroy, complete_scanned_resource)
      should_not be_able_to(:destroy, admin_file)

      should be_able_to(:create, Template.new)
      should be_able_to(:read, Template.new)
      should be_able_to(:update, Template.new)
      should be_able_to(:destroy, Template.new)
    }
  end

  describe 'as an image editor' do
    let(:creating_user) { image_editor }
    let(:current_user) { image_editor }

    it {
      should be_able_to(:read, open_scanned_resource)
      should be_able_to(:manifest, open_scanned_resource)
      should be_able_to(:pdf, open_scanned_resource)
      should be_able_to(:color_pdf, open_scanned_resource)
      should be_able_to(:read, campus_only_scanned_resource)
      should be_able_to(:read, private_scanned_resource)
      should be_able_to(:read, pending_scanned_resource)
      should be_able_to(:read, metadata_review_scanned_resource)
      should be_able_to(:read, final_review_scanned_resource)
      should be_able_to(:read, complete_scanned_resource)
      should be_able_to(:read, takedown_scanned_resource)
      should be_able_to(:read, flagged_scanned_resource)
      should be_able_to(:manifest, pending_scanned_resource)
      should be_able_to(:download, image_editor_file)
      should be_able_to(:file_manager, open_scanned_resource)
      should be_able_to(:file_manager, open_multi_volume_work)
      should be_able_to(:save_structure, open_scanned_resource)
      should be_able_to(:update, open_scanned_resource)
      should be_able_to(:create, ScannedResource.new)
      should be_able_to(:create, FileSet.new)
      should be_able_to(:destroy, image_editor_file)
      should be_able_to(:destroy, pending_scanned_resource)

      should be_able_to(:manifest, presenter(pending_scanned_resource))

      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
      should_not be_able_to(:complete, pending_scanned_resource)
      should_not be_able_to(:destroy, complete_scanned_resource)
      should_not be_able_to(:destroy, admin_file)
      should_not be_able_to(:destroy, ephemera_editor_file)
    }
    it "can create works" do
      expect(subject.can_create_any_work?).to be true
    end
  end

  describe 'as an editor' do
    let(:creating_user) { image_editor }
    let(:current_user) { editor }

    it {
      should be_able_to(:read, open_scanned_resource)
      should be_able_to(:read, campus_only_scanned_resource)
      should be_able_to(:read, private_scanned_resource)
      should be_able_to(:read, pending_scanned_resource)
      should be_able_to(:read, metadata_review_scanned_resource)
      should be_able_to(:read, final_review_scanned_resource)
      should be_able_to(:read, complete_scanned_resource)
      should be_able_to(:read, takedown_scanned_resource)
      should be_able_to(:read, flagged_scanned_resource)
      should be_able_to(:manifest, open_scanned_resource)
      should be_able_to(:pdf, open_scanned_resource)
      should be_able_to(:color_pdf, open_scanned_resource)
      should be_able_to(:file_manager, open_scanned_resource)
      should be_able_to(:file_manager, open_multi_volume_work)
      should be_able_to(:save_structure, open_scanned_resource)
      should be_able_to(:update, open_scanned_resource)

      should_not be_able_to(:download, image_editor_file)
      should_not be_able_to(:create, ScannedResource.new)
      should_not be_able_to(:create, FileSet.new)
      should_not be_able_to(:destroy, image_editor_file)
      should_not be_able_to(:destroy, pending_scanned_resource)
      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
      should_not be_able_to(:complete, pending_scanned_resource)
      should_not be_able_to(:destroy, complete_scanned_resource)
      should_not be_able_to(:destroy, admin_file)
    }
    it "cannot create works" do
      expect(subject.can_create_any_work?).to be false
    end
  end

  describe 'as a completer' do
    let(:creating_user) { image_editor }
    let(:current_user) { completer }

    it {
      should be_able_to(:read, open_scanned_resource)
      should be_able_to(:read, campus_only_scanned_resource)
      should be_able_to(:read, private_scanned_resource)
      should be_able_to(:read, pending_scanned_resource)
      should be_able_to(:read, metadata_review_scanned_resource)
      should be_able_to(:read, final_review_scanned_resource)
      should be_able_to(:read, complete_scanned_resource)
      should be_able_to(:read, takedown_scanned_resource)
      should be_able_to(:read, flagged_scanned_resource)
      should be_able_to(:manifest, open_scanned_resource)
      should be_able_to(:pdf, open_scanned_resource)
      should be_able_to(:color_pdf, open_scanned_resource)
      should be_able_to(:file_manager, open_scanned_resource)
      should be_able_to(:file_manager, open_multi_volume_work)
      should be_able_to(:save_structure, open_scanned_resource)
      should be_able_to(:update, open_scanned_resource)
      should be_able_to(:complete, pending_scanned_resource)

      should_not be_able_to(:download, image_editor_file)
      should_not be_able_to(:create, ScannedResource.new)
      should_not be_able_to(:create, FileSet.new)
      should_not be_able_to(:destroy, image_editor_file)
      should_not be_able_to(:destroy, pending_scanned_resource)
      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
      should_not be_able_to(:destroy, complete_scanned_resource)
      should_not be_able_to(:destroy, admin_file)
    }
    it "cannot create works" do
      expect(subject.can_create_any_work?).to be false
    end
  end

  describe 'as a fulfiller' do
    let(:creating_user) { image_editor }
    let(:current_user) { fulfiller }

    it {
      should be_able_to(:read, open_scanned_resource)
      should be_able_to(:read, campus_only_scanned_resource)
      should be_able_to(:read, private_scanned_resource)
      should be_able_to(:read, pending_scanned_resource)
      should be_able_to(:read, metadata_review_scanned_resource)
      should be_able_to(:read, final_review_scanned_resource)
      should be_able_to(:read, complete_scanned_resource)
      should be_able_to(:read, takedown_scanned_resource)
      should be_able_to(:read, flagged_scanned_resource)
      should be_able_to(:manifest, open_scanned_resource)
      should be_able_to(:pdf, open_scanned_resource)
      should be_able_to(:download, image_editor_file)

      should_not be_able_to(:file_manager, open_scanned_resource)
      should_not be_able_to(:file_manager, open_multi_volume_work)
      should_not be_able_to(:save_structure, open_scanned_resource)
      should_not be_able_to(:update, open_scanned_resource)
      should_not be_able_to(:create, ScannedResource.new)
      should_not be_able_to(:create, FileSet.new)
      should_not be_able_to(:destroy, image_editor_file)
      should_not be_able_to(:destroy, pending_scanned_resource)
      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
      should_not be_able_to(:complete, pending_scanned_resource)
      should_not be_able_to(:destroy, complete_scanned_resource)
      should_not be_able_to(:destroy, admin_file)
    }
    it "cannot create works" do
      expect(subject.can_create_any_work?).to be false
    end
  end

  describe 'as a curator' do
    let(:creating_user) { image_editor }
    let(:current_user) { curator }

    it {
      should be_able_to(:read, open_scanned_resource)
      should be_able_to(:read, campus_only_scanned_resource)
      should be_able_to(:read, private_scanned_resource)
      should be_able_to(:read, metadata_review_scanned_resource)
      should be_able_to(:read, final_review_scanned_resource)
      should be_able_to(:read, complete_scanned_resource)
      should be_able_to(:read, takedown_scanned_resource)
      should be_able_to(:read, flagged_scanned_resource)
      should be_able_to(:manifest, open_scanned_resource)
      should be_able_to(:pdf, open_scanned_resource)

      should_not be_able_to(:read, pending_scanned_resource)
      should_not be_able_to(:download, image_editor_file)
      should_not be_able_to(:file_manager, open_scanned_resource)
      should_not be_able_to(:file_manager, open_multi_volume_work)
      should_not be_able_to(:save_structure, open_scanned_resource)
      should_not be_able_to(:update, open_scanned_resource)
      should_not be_able_to(:create, ScannedResource.new)
      should_not be_able_to(:create, FileSet.new)
      should_not be_able_to(:destroy, image_editor_file)
      should_not be_able_to(:destroy, pending_scanned_resource)
      should_not be_able_to(:destroy, complete_scanned_resource)
      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
      should_not be_able_to(:complete, pending_scanned_resource)
      should_not be_able_to(:destroy, admin_file)
    }
    it "cannot create works" do
      expect(subject.can_create_any_work?).to be false
    end
  end

  describe 'as a campus user' do
    let(:creating_user) { FactoryGirl.create(:image_editor) }
    let(:current_user) { campus_user }

    it {
      should be_able_to(:read, open_scanned_resource)
      should be_able_to(:read, campus_only_scanned_resource)
      should be_able_to(:read, complete_scanned_resource)
      should be_able_to(:read, flagged_scanned_resource)
      should be_able_to(:manifest, open_scanned_resource)
      should be_able_to(:manifest, campus_only_scanned_resource)
      should be_able_to(:manifest, complete_scanned_resource)
      should be_able_to(:manifest, flagged_scanned_resource)
      should be_able_to(:pdf, open_scanned_resource)
      should be_able_to(:pdf, campus_only_scanned_resource)
      should be_able_to(:pdf, complete_scanned_resource)
      should be_able_to(:pdf, flagged_scanned_resource)

      should_not be_able_to(:read, private_scanned_resource)
      should_not be_able_to(:read, pending_scanned_resource)
      should_not be_able_to(:read, metadata_review_scanned_resource)
      should_not be_able_to(:read, final_review_scanned_resource)
      should_not be_able_to(:read, takedown_scanned_resource)
      should_not be_able_to(:download, image_editor_file)
      should_not be_able_to(:file_manager, open_scanned_resource)
      should_not be_able_to(:file_manager, open_multi_volume_work)
      should_not be_able_to(:save_structure, open_scanned_resource)
      should_not be_able_to(:update, open_scanned_resource)
      should_not be_able_to(:create, ScannedResource.new)
      should_not be_able_to(:create, FileSet.new)
      should_not be_able_to(:destroy, image_editor_file)
      should_not be_able_to(:destroy, pending_scanned_resource)
      should_not be_able_to(:destroy, complete_scanned_resource)
      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
      should_not be_able_to(:complete, pending_scanned_resource)
      should_not be_able_to(:destroy, admin_file)

      should_not be_able_to(:manifest, needs_qa_ephemera_folder)
      should be_able_to(:manifest, complete_ephemera_folder)
    }
    it "cannot create works" do
      expect(subject.can_create_any_work?).to be false
    end
  end

  describe 'as an anonymous user' do
    let(:creating_user) { FactoryGirl.create(:image_editor) }
    let(:current_user) { nil }
    let(:color_enabled_resource) {
      FactoryGirl.build(:open_scanned_resource, user: creating_user, state: 'complete', pdf_type: ['color'])
    }
    let(:no_pdf_scanned_resource) {
      FactoryGirl.build(:open_scanned_resource, user: creating_user, state: 'complete', pdf_type: [])
    }

    it {
      should be_able_to(:read, open_scanned_resource)
      should be_able_to(:manifest, open_scanned_resource)
      should be_able_to(:pdf, open_scanned_resource)
      should be_able_to(:read, complete_scanned_resource)
      should be_able_to(:manifest, complete_scanned_resource)
      should be_able_to(:manifest, presenter(complete_scanned_resource))
      should be_able_to(:read, flagged_scanned_resource)
      should be_able_to(:manifest, flagged_scanned_resource)
      should be_able_to(:color_pdf, color_enabled_resource)
      should be_able_to(:download, external_metadata_file)

      should_not be_able_to(:pdf, no_pdf_scanned_resource)
      should_not be_able_to(:flag, open_scanned_resource)
      should_not be_able_to(:read, campus_only_scanned_resource)
      should_not be_able_to(:read, private_scanned_resource)
      should_not be_able_to(:read, pending_scanned_resource)
      should_not be_able_to(:read, metadata_review_scanned_resource)
      should_not be_able_to(:read, final_review_scanned_resource)
      should_not be_able_to(:read, takedown_scanned_resource)
      should_not be_able_to(:download, image_editor_file)
      should_not be_able_to(:file_manager, open_scanned_resource)
      should_not be_able_to(:file_manager, open_multi_volume_work)
      should_not be_able_to(:save_structure, open_scanned_resource)
      should_not be_able_to(:update, open_scanned_resource)
      should_not be_able_to(:create, ScannedResource.new)
      should_not be_able_to(:create, FileSet.new)
      should_not be_able_to(:destroy, image_editor_file)
      should_not be_able_to(:destroy, pending_scanned_resource)
      should_not be_able_to(:destroy, complete_scanned_resource)
      should_not be_able_to(:create, Role.new)
      should_not be_able_to(:destroy, role)
      should_not be_able_to(:complete, pending_scanned_resource)
      should_not be_able_to(:destroy, admin_file)
    }
    it "cannot create works" do
      expect(subject.can_create_any_work?).to be false
    end
  end
end

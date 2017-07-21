require 'rails_helper'

RSpec.feature 'Editing a FileSet', type: :feature do
  let(:user) { FactoryGirl.create(:image_editor) }
  let(:image_resource) do
    FactoryGirl.build(:image_work,
                      id: 'test',
                      user: user)
  end
  let(:parent_presenter) do
    ImageWorkShowPresenter.new(
      SolrDocument.new(
        image_resource.to_solr
      ), nil
    )
  end
  let(:file_title) { 'Some kind of title' }
  let(:file_set) { FactoryGirl.create(:file_set, user: user, title: [file_title], visibility: 'open') }
  let(:file) { File.open(File.join(fixture_path, '/files/image.png')) }

  before do
    sign_in user
    Hydra::Works::AddFileToFileSet.call(file_set, file, :original_file)
    image_resource.ordered_members << file_set
    image_resource.save!
  end

  context 'when the user sets an attached file to be privately accessible' do
    it 'updates the visibility of the file' do
      visit polymorphic_path [:edit, parent_presenter.member_presenters.first]
      expect(page).to have_content "Edit #{file_title}"
      choose('Private')
      click_button 'Update Attached File'
      visit polymorphic_path [:edit, parent_presenter.member_presenters.first]
      expect(find("#file_set_visibility_restricted")).to be_checked
    end
  end
end

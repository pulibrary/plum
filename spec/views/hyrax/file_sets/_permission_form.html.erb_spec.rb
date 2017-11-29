# frozen_string_literal: true
require 'rails_helper'

describe 'hyrax/file_sets/_permission_form.html.erb', type: :view do
  let(:user) { instance_double(User, user_key: 'sarah') }
  let(:curation_concern) do
    FactoryGirl.build(:image_work,
                      id: 'test',
                      title: ['an image work'],
                      creator: ['John Smith'],
                      date_created: ['1595-01-02'],
                      rights: ['Public Domain'])
  end
  let(:file_set) do
    file_set = FactoryGirl.build(:file_set, id: '123', title: ['an image file'], depositor: user.user_key, user: user, visibility: 'open')
    curation_concern.ordered_members << file_set
    curation_concern.save
    file_set
  end

  let(:form) do
    view.simple_form_for(file_set, url: '/update') do |fs_form|
      return fs_form
    end
  end

  before do
    allow(view).to receive(:f).and_return(form)
    render partial: 'hyrax/file_sets/permission_form', locals: { file_set: file_set }
  end

  it "draws the permissions form without error" do
    expect(rendered).to have_css('#permissions_display')
    expect(rendered).to have_css('.set-access-controls')
  end
end

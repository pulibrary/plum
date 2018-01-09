# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MapSet do
  subject { map_set }
  let(:nkc) { 'http://rightsstatements.org/vocab/NKC/1.0/' }
  let(:map_set) { FactoryGirl.build(:map_set, source_metadata_identifier: ['12345'], rights_statement: [nkc]) }
  let(:image_work1) { FactoryGirl.build(:image_work, title: ['Sheet 1'], rights_statement: [nkc]) }
  let(:image_work2) { FactoryGirl.build(:image_work, title: ['Sheet 2'], rights_statement: [nkc]) }
  let(:file_set) { FactoryGirl.build(:file_set) }
  let(:reloaded) { described_class.find(map_set.id) }
  describe 'has image work members' do
    before do
      subject.ordered_members = [image_work1, image_work2]
      image_work1.thumbnail = file_set
    end
    it 'has image works' do
      expect(subject.ordered_members).to eq [image_work1, image_work2]
    end
    it 'can persist when it has a thumbnail set to image work' do
      subject.thumbnail = image_work1
      expect(subject.save).to eq true
      expect(subject.thumbnail_id).to eq file_set.id
    end
  end

  describe 'cleans up members when destroyed' do
    before do
      image_work1.save
      image_work2.save
      subject.members = [image_work1, image_work2]
      subject.save
      subject.destroy
    end
    it 'deletes them' do
      expect { ActiveFedora::Base.find(image_work1.id) }.to raise_error(Ldp::Gone)
      expect { ActiveFedora::Base.find(image_work2.id) }.to raise_error(Ldp::Gone)
    end
  end
end

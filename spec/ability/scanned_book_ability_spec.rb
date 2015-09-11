require 'rails_helper'
require "cancan/matchers"

describe Ability do
  subject { described_class.new(current_user) }

  let(:scanned_book) {
    FactoryGirl.create(:scanned_book, user: creating_user)
  }

  let(:open_scanned_book) { scanned_book }

  let(:campus_only_scanned_book) {
    FactoryGirl.create(:campus_only_scanned_book, user: creating_user)
  }

  let(:user) {
    FactoryGirl.create(:user)
  }

  describe 'without embargo' do
    describe 'as a scanned book creator' do
      let(:creating_user) { user }
      let(:current_user) { FactoryGirl.create(:scanned_book_creator) }
      it { should be_able_to(:create, ScannedBook.new) }
      it { should be_able_to(:create, GenericFile.new) }
      it { should be_able_to(:read, scanned_book) }
      it { should be_able_to(:pdf, scanned_book) }
      it { should be_able_to(:update, scanned_book) }
      it { should_not be_able_to(:destroy, scanned_book) }
    end

    describe 'as an admin' do
      let(:manager_user) { FactoryGirl.create(:admin) }
      let(:creating_user) { user }
      let(:current_user) { manager_user }
      it { should be_able_to(:create, ScannedBook.new) }
      it { should be_able_to(:create, GenericFile.new) }
      it { should be_able_to(:read, scanned_book) }
      it { should be_able_to(:pdf, scanned_book) }
      it { should be_able_to(:update, scanned_book) }
      it { should be_able_to(:destroy, scanned_book) }
    end

    describe 'as a campus user' do
      let(:creating_user) { FactoryGirl.create(:user) }
      let(:current_user) { user }
      it { should_not be_able_to(:create, ScannedBook.new) }
      it { should_not be_able_to(:create, GenericFile.new) }
      it { should be_able_to(:read, campus_only_scanned_book) }
      it { should be_able_to(:pdf, scanned_book) }
      it { should_not be_able_to(:update, scanned_book) }
      it { should_not be_able_to(:destroy, scanned_book) }
    end

    describe 'a guest user' do
      let(:creating_user) { FactoryGirl.create(:user) }
      let(:current_user) { nil }
      it { should_not be_able_to(:create, ScannedBook.new) }
      it { should_not be_able_to(:create, GenericFile.new) }
      it { should_not be_able_to(:read, campus_only_scanned_book) }
      it { should_not be_able_to(:pdf, campus_only_scanned_book) }
      it { should_not be_able_to(:update, scanned_book) }
      it { should_not be_able_to(:destroy, scanned_book) }
      it { should be_able_to(:read, open_scanned_book) }
      it { should be_able_to(:pdf, open_scanned_book) }
    end
  end
end

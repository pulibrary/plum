# Generated via
#  `rails generate geo_concerns:install`
require 'rails_helper'

describe Hyrax::ImageWorksController do
  it { is_expected.to be_kind_of(GeoConcerns::ImageWorksControllerBehavior) }

  describe '#show_presenter' do
    subject { described_class.new.show_presenter }
    it { is_expected.to eq(ImageWorkShowPresenter) }
  end
end

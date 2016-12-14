# Generated via
#  `rails generate geo_concerns:install`
require 'rails_helper'

describe CurationConcerns::VectorWorksController do
  it { is_expected.to be_kind_of(GeoConcerns::VectorWorksControllerBehavior) }

  describe '#show_presenter' do
    subject { described_class.new.show_presenter }
    it { is_expected.to eq(VectorWorkShowPresenter) }
  end
end

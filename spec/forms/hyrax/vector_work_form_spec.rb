# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::VectorWorkForm do
  let(:work) { VectorWork.new }
  let(:form) { described_class.new(work, nil, nil) }

  describe "#required_fields" do
    subject { form.required_fields }
    it { is_expected.to eq [:title, :rights_statement, :coverage] }
  end

  describe "#primary_terms" do
    subject { form.primary_terms }
    it { is_expected.to include(:should_populate_metadata) }
    it { is_expected.not_to include [:holding_location, :pdf_type] }
  end

  describe "#secondary_terms" do
    subject { form.secondary_terms }
    it { is_expected.not_to include(:nav_date, :portion_note, :related_url) }
    it do
      is_expected.to include(:spatial,
                             :temporal,
                             :issued,
                             :cartographic_projection)
    end
  end
end

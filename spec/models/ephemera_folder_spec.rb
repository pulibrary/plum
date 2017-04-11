# Generated via
#  `rails generate hyrax:work EphemeraFolder`
require 'rails_helper'

RSpec.describe EphemeraFolder do
  subject(:folder) { FactoryGirl.build(:ephemera_folder) }
  it "has a valid factory" do
    expect(folder).to be_valid
  end

  describe "indexing" do
    it "indexes folder_number" do
      expect(subject.to_solr["folder_number_ssim"]).to eq folder.folder_number.map(&:to_s)
    end
  end
end

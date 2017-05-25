require 'rails_helper'

RSpec.describe WordBoundariesRunner do
  let(:file_set) { FileSet.new }


  before do
    allow(file_set).to receive(:id).and_return('123')
    file_set.save
    subject { described_class.new('123') }  
  end


  context "when HOCR file is available" do
    it "creates a word boundary file" do

    end
  end

  context "when no HOCR file exists" do
    it "does not create a file" do

      subject.stub(:hocr_exists?).and_return(false)
      subject.create.should be_false
    end
  end
end

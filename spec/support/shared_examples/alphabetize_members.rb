RSpec.shared_examples "alphabetize_members" do
  # rubocop:disable RSpec/DescribeClass
  describe "#alphabetize_members" do
    let(:fileA) { FactoryGirl.create :file_set, label: 'A' }
    let(:fileB) { FactoryGirl.create :file_set, label: 'B' }
    before do
      sign_in FactoryGirl.create(:admin)
      request.env['HTTP_REFERER'] = ':back'
      curation_concern.update_attributes(ordered_members: [fileB, fileA])
      patch :alphabetize_members, id: curation_concern.id
    end
    it "reorders filesets by label" do
      expect(curation_concern.ordered_members.to_a.first).to eq fileB
      curation_concern.reload
      expect(curation_concern.ordered_members.to_a.first).to eq fileA
    end
    it "redirects to :back" do
      expect(response).to redirect_to ':back'
    end
  end
end

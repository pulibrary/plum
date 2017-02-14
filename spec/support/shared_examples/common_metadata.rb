RSpec.shared_examples "common metadata" do
  # rubocop:disable RSpec/DescribeClass
  describe "#identifier" do
    # rubocop:enable RSpec/DescribeClass
    # tests workaround for modifying property arity via schema inclusion
    it "returns false on multiple? check" do
      expect(subject.class.multiple?(:identifier)).not_to be true
    end
  end
end

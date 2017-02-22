# require 'rails_helper'
#
# describe Geoserver do
#   let(:file_set) { instance_double("FileSet") }
#   let(:visibility) { 'open' }
#   let(:geo_derivatives_path) { 'path/to/geo-derivatives' }
#   let(:plum_config) { { geo_derivatives_path: geo_derivatives_path } }
#   let(:relative_derivative_path) { '/d5/13/8j/d8/7v-display_vector/test.shp' }
#   let(:path) { "#{geo_derivatives_path}#{relative_derivative_path}" }
#
#   subject { described_class.new file_set, path }
#
#   before do
#     allow(file_set).to receive(:visibility).and_return(visibility)
#     allow(Plum).to receive(:config).and_return(plum_config)
#   end
#
#   describe '#base_path' do
#     it 'returns the correct base path to the derivative' do
#       expect(subject.send(:base_path, path)).to eq(relative_derivative_path)
#     end
#   end
# end

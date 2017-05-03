require 'rails_helper'
include SimpleForm::ActionViewExtensions::FormHelper

RSpec.describe 'records/edit_fields/_identifier.html.erb' do
  before do
    allow(view).to receive(:f).and_return(simple_form_for(form))
    allow(view).to receive(:key).and_return(:identifier)
    render
  end

  context 'with an ephemera box' do
    let(:form) { Hyrax::EphemeraBoxForm.new(EphemeraBox.new, nil, nil) }
    it 'auto-focuses the barcode field' do
      expect(rendered).to have_selector 'input#ephemera_box_identifier[@autofocus="autofocus"]'
    end
  end

  context 'with an ephemera box' do
    let(:form) { Hyrax::ScannedResourceForm.new(ScannedResource.new, nil, nil) }
    it 'auto-focuses the barcode field' do
      expect(rendered).not_to have_selector 'input#scanned_resource_identifier[@autofocus="autofocus"]'
    end
  end
end

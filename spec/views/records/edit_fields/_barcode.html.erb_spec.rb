# frozen_string_literal: true
require 'rails_helper'
include SimpleForm::ActionViewExtensions::FormHelper

RSpec.describe 'records/edit_fields/_barcode.html.erb' do
  before do
    allow(view).to receive(:f).and_return(simple_form_for(form))
    allow(view).to receive(:key).and_return(:barcode)
    render
  end

  context 'with an ephemera box' do
    let(:form) { Hyrax::EphemeraBoxForm.new(EphemeraBox.new, nil, nil) }
    it 'auto-focuses the barcode field' do
      expect(rendered).to have_selector 'input#ephemera_box_barcode[@autofocus="autofocus"]'
    end
  end

  context 'with an ephemera folder' do
    let(:form) { Hyrax::EphemeraFolderForm.new(EphemeraFolder.new, nil, nil) }
    it 'auto-focuses the barcode field' do
      expect(rendered).to have_selector 'input#ephemera_folder_barcode[@autofocus="autofocus"]'
    end
  end
end

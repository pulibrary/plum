# frozen_string_literal: true
module OsdModalHelper
  def osd_modal_for(id, &block)
    if !id
      yield
    else
      content_tag :span, class: 'ignore-select', data: { modal_manifest: "#{IIIFPath.new(id)}/info.json" }, &block
    end
  end
end

module OsdModalHelper
  def osd_modal_for(id, &block)
    content_tag :span, class: 'ignore-select', data: { modal_manifest: IIIFPath.new(id).to_s }, &block
  end
end

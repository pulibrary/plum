class DynamicShowPresenter
  def new(*args)
    solr_doc = args.first
    if solr_doc.type == "ScannedResource"
      ScannedResourceShowPresenter.new(*args)
    elsif solr_doc.type == "MultiVolumeWork"
      MultiVolumeWorkShowPresenter.new(*args)
    elsif solr_doc.type == "ImageWork"
      ImageWorkShowPresenter.new(*args)
    elsif solr_doc.type == "RasterWork"
      RasterWorkShowPresenter.new(*args)
    elsif solr_doc.type == "VectorWork"
      VectorWorkShowPresenter.new(*args)
    else
      FileSetPresenter.new(*args)
    end
  end
end

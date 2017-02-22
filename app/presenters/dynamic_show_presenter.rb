class DynamicShowPresenter
  def new(*args)
    solr_doc = args.first
    if solr_doc.type == "ScannedResource"
      ScannedResourceShowPresenter.new(*args)
    elsif solr_doc.type == "MultiVolumeWork"
      MultiVolumeWorkShowPresenter.new(*args)
    else
      FileSetPresenter.new(*args)
    end
  end
end

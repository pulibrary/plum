class MultiVolumeWorkShowPresenter < CurationConcernsShowPresenter
  def viewing_hint
    'multi-part'
  end

  class DynamicShowPresenter
    def new(*args)
      solr_doc = args.first
      if solr_doc.fetch("has_model_ssim").include? "ScannedResource"
        ScannedResourceShowPresenter.new(*args)
      elsif solr_doc.fetch("has_model_ssim").include? "MultiVolumeWork"
        MultiVolumeWorkShowPresenter.new(*args)
      else
        FileSetPresenter.new(*args)
      end
    end
  end

  self.work_presenter_class = DynamicShowPresenter.new
  self.file_presenter_class = FileSetPresenter
end

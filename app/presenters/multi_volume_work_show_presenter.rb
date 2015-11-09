class MultiVolumeWorkShowPresenter < CurationConcernsShowPresenter
  def member_presenters
    @scanned_resources ||=
      begin
        ids = solr_document.fetch('member_ids_ssim', [])
        CurationConcerns::PresenterFactory.build_presenters(ids, ::ScannedResourceShowPresenter, current_ability)
      end
  end
end

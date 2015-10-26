class MultiVolumeWorkShowPresenter < CurationConcernsShowPresenter
  def member_presenters
    @scanned_resources ||= begin
      # change to 'member_ids_ssim' when curation_concerns#434 is merged
      ids = solr_document.fetch('file_set_ids_ssim', [])
      CurationConcerns::PresenterFactory.build_presenters(ids, ::ScannedResourceShowPresenter, current_ability)
    end
  end
end

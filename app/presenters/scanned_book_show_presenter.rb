class ScannedBookShowPresenter < CurationConcerns::GenericWorkShowPresenter
  delegate :date_created, :viewing_hint, :viewing_direction, to: :solr_document

  def file_presenters
    @generic_files ||= begin
      ids = solr_document.fetch('generic_file_ids_ssim', [])
      CurationConcerns::PresenterFactory.build_presenters(ids, GenericFilePresenter, current_ability)
    end
  end
end

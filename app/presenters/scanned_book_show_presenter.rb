class ScannedBookShowPresenter < CurationConcerns::GenericWorkShowPresenter
  delegate :date_created, :viewing_hint, :viewing_direction, to: :solr_document

  def file_presenters
    @generic_files ||= begin
      CurationConcerns::PresenterFactory.build_presenters(generic_file_ids, GenericFilePresenter, current_ability)
    end
  end

  def generic_file_ids
    solr_document.fetch('generic_file_ids_ssim', [])
  end
end

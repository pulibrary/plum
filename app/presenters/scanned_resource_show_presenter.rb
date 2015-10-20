class ScannedResourceShowPresenter < CurationConcerns::WorkShowPresenter
  delegate :date_created, :viewing_hint, :viewing_direction, to: :solr_document

  def file_presenters
    @file_sets ||= begin
      CurationConcerns::PresenterFactory.build_presenters(file_set_ids, FileSetPresenter, current_ability)
    end
  end

  def file_set_ids
    solr_document.fetch('file_set_ids_ssim', [])
  end
end

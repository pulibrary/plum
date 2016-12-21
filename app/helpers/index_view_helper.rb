module IndexViewHelper
  # Limit the number of subjects displayed on index page.
  # Mainly because of geo works.
  def index_subject(args)
    args[:document].subject.take(7).join("<br/>")
  end
end

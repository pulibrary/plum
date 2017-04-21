class DynamicShowPresenter
  def new(*args)
    type = args.first.type
    klass = begin
              "#{type}ShowPresenter".constantize
            rescue
              nil
            end
    klass ||= begin
                "#{type}Presenter".constantize
              rescue
                nil
              end
    klass ||= FileSetPresenter
    klass.new(*args)
  end
end

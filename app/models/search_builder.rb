class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Hydra::AccessControlsEnforcement
  include CurationConcerns::SearchFilters

  self.default_processor_chain += [
    :hide_parented_resources, :join_from_parent,
    :hide_incomplete
  ]

  def self.show_actions
    [:show, :manifest, :structure, :pdf]
  end

  def hide_parented_resources(solr_params)
    return if show_action? || file_manager?
    solr_params[:fq] ||= []
    solr_params[:fq] << "!#{ActiveFedora.index_field_mapper.solr_name('ordered_by', :symbol)}:['' TO *]"
  end

  def join_from_parent(solr_params)
    return if show_action?
    solr_params[:q] = JoinChildrenQuery.new(solr_params[:q]).to_s
  end

  def hide_incomplete(solr_params)
    # admin route causes errors with current_ability.
    return if blacklight_params.empty?
    return if current_ability.unreadable_states.blank?
    solr_params[:fq] ||= []
    state_field = Solrizer.solr_name('workflow_state_name', :symbol)
    state_string = readable_states.map { |state| "#{state_field}:#{state}" }.join(" OR ")
    state_string += " OR " unless state_string == ""
    state_string += "has_model_ssim:Collection"
    solr_params[:fq] << state_string
  end

  def readable_states
    all_states - unreadable_states
  end

  def all_states
    Sipity::Workflow.all.map { |w| w.workflow_states.map(&:name) }.flatten.uniq
  end

  delegate :unreadable_states, to: :current_ability

  def show_action?
    return true unless blacklight_params[:action]
    self.class.show_actions.include? blacklight_params[:action].to_sym
  end

  def file_manager?
    return true unless blacklight_params[:action]
    blacklight_params[:action].to_sym == :file_manager
  end
end

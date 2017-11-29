# frozen_string_literal: true
class SearchBuilder < Hyrax::CatalogSearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Hydra::AccessControlsEnforcement
  include Hyrax::SearchFilters
  delegate :unreadable_states, to: :current_ability

  self.default_processor_chain += [
    :hide_parented_resources, :join_from_parent,
    :hide_incomplete
  ]

  self.default_processor_chain -= [
    :show_works_or_works_that_contain_files
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

  # Allow people to see all collections as ones they can ingest into.
  def gated_discovery_filters(permission_types = discovery_permissions, ability = current_ability)
    return [] if models == collection_classes
    super
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

  def show_action?
    return true unless blacklight_params[:action]
    self.class.show_actions.include? blacklight_params[:action].to_sym
  end

  def file_manager?
    return true unless blacklight_params[:action]
    blacklight_params[:action].to_sym == :file_manager
  end
end

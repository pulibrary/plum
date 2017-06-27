class StateBadge
  include ActionView::Context
  include ActionView::Helpers::TagHelper
  attr_reader :actions, :current_state

  def initialize(work_presenter)
    @actions = work_presenter.workflow.actions
    @current_state = work_presenter.workflow.state
  end

  def render
    badge(current_state)
  end

  def render_buttons
    actions.collect do |action_state, _label|
      render_radio_button(action_state)
    end.join.html_safe
  end

  private

    def render_radio_button(action_state)
      content_tag :div, class: 'radio' do
        content_tag :label do
          input_tag(action_state) + badge(action_state) + label(action_state)
        end
      end
    end

    def input_tag(state)
      tag(:input, id: field_id(state), name: "workflow_action[name]", type: :radio, value: state)
    end

    def badge(state)
      content_tag(:span, I18n.t("state.#{state}.label"), class: "label #{dom_label_class(state)}", for: field_id(state))
    end

    def label(state)
      " " + I18n.t("state.#{state}.desc")
    end

    def dom_label_class(state)
      state_classes[state.to_sym] if state
    end

    def state_classes
      @state_classes ||= {
        pending: 'label-default',
        needs_qa: 'label-info',
        metadata_review: 'label-info',
        final_review: 'label-primary',
        complete: 'label-success',
        flagged: 'label-warning',
        takedown: 'label-danger',
        ready_to_ship: 'label-info',
        shipped: 'label-info',
        received: 'label-default',
        all_in_production: 'label-success'
      }
    end

    def field_id(state)
      "workflow_action_name_#{state}"
    end
end

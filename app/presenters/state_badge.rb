class StateBadge
  include ActionView::Context
  include ActionView::Helpers::TagHelper

  def initialize(type, state = nil)
    @type = type.underscore
    @state = StateWorkflow.new state
  end

  def render
    label = I18n.t("state.#{current_state}.label")
    content_tag(:span, label, title: label, class: "label #{dom_label_class}")
  end

  def render_buttons
    html = render_radio_button(current_state, checked: true)
    @state.valid_transitions.each do |valid_state|
      html += render_radio_button(valid_state)
    end
    html
  end

  def render_hidden
    tag :input, id: "#{field_id}", name: field_name, type: :hidden, value: current_state
  end

  private

    def render_radio_button(state, checked = false)
      content_tag :label, class: 'radio' do
        tag(:input, id: field_id(state), name: field_name, type: :radio, value: state, checked: checked) +
          content_tag(:span, I18n.t("state.#{state}.label"), class: "label #{dom_label_class(state)}", for: field_id(state)) +
          " " + I18n.t("state.#{state}.desc")
      end
    end

    def dom_label_class(state = current_state)
      state_classes[state]
    end

    def state_classes
      @state_classes ||= {
        pending: 'label-default',
        metadata_review: 'label-info',
        final_review: 'label-primary',
        complete: 'label-success',
        flagged: 'label-warning',
        takedown: 'label-danger'
      }
    end

    def current_state
      @state.aasm.current_state
    end

    def field_name
      "#{@type}[state]"
    end

    def field_id(state = current_state)
      "#{@type}_state_#{state}"
    end
end

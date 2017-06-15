module Hyrax
  class TemplatesController < ApplicationController
    authorize_resource
    def index
      @templates = Template.all
    end

    def edit
      @template = Template.find(params[:id])
      form = form_class.new(class_type.new(@template.params.except(:member_of_collection_ids)), current_ability, self)
      @form = TemplateForm.new(@template, form)
    end

    def new
      @form = TemplateForm.new(Template.new, form_class.new(class_type.new, current_ability, self))
    end

    def create
      t = Template.new(template_label: template_params[:template_label], params: model_attributes, template_class: params[:class_type])
      redirect_to create_path if t.save
    end

    def create_path
      if params["class_type"] == "EphemeraFolder" && params["parent_id"]
        polymorphic_path([main_app, :hyrax, :ephemera_box], id: params["parent_id"])
      else
        main_app.templates_path
      end
    end

    def update
      @template = Template.find(params[:id])
      @template.template_label = template_params[:template_label]
      @template.params = model_attributes
      @template_class = params[:class_type]
      redirect_to main_app.templates_path if @template.save
    end

    def destroy
      @template = Template.find(params[:id])
      @template.destroy
      redirect_to :back
    end

    def class_type
      params[:class_type].constantize
    end

    def form_class
      "Hyrax::#{params[:class_type]}Form".constantize
    end

    def _prefixes
      # This allows us to use the templates in hyrax/base, while prefering
      # our local paths. Thus we are unable to just override `self.local_prefixes`
      @_prefixes ||= super + ['hyrax/base']
    end

    def repository
      @repository ||= Hyrax::ScannedResourcesController.new.repository
    end

    def template_params
      params.require(:template).permit(:template_label).to_h
    end

    def model_attributes
      form_class.model_attributes(params[:template]).to_h.merge(extra_attributes)
    end

    def extra_attributes
      if params[:class_type] == "EphemeraFolder"
        {
          "ephemera_project_id" => ActiveFedora::Base.find(params[:template][:box_id]).ephemera_project.first
        }
      else
        {}
      end
    end
  end
end

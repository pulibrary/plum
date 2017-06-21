class EphemeraProjectsController < ApplicationController
  before_action :set_ephemera_project, only: [:show, :edit, :update, :destroy]
  authorize_resource only: [:new, :edit, :create, :update, :destroy]

  # GET /ephemera_projects
  # GET /ephemera_projects.json
  def index
    @ephemera_projects = EphemeraProject.all
  end

  # GET /ephemera_projects/1
  # GET /ephemera_projects/1.json
  def show
    @templates = Template.where(template_class: "EphemeraFolder").select { |x| x.params["ephemera_project_id"] == @ephemera_project.id.to_s }
  end

  # GET /ephemera_projects/new
  def new
    @ephemera_project = EphemeraProject.new
  end

  # GET /ephemera_projects/1/edit
  def edit
  end

  # POST /ephemera_projects
  # POST /ephemera_projects.json
  def create
    @ephemera_project = EphemeraProject.new(ephemera_project_params)

    respond_to do |format|
      if @ephemera_project.save
        format.html { redirect_to @ephemera_project, notice: 'Ephemera project was successfully created.' }
        format.json { render :show, status: :created, location: @ephemera_project }
      else
        format.html { render :new }
        format.json { render json: @ephemera_project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ephemera_projects/1
  # PATCH/PUT /ephemera_projects/1.json
  def update
    respond_to do |format|
      if @ephemera_project.update(ephemera_project_params)
        format.html { redirect_to @ephemera_project, notice: 'Ephemera project was successfully updated.' }
        format.json { render :show, status: :ok, location: @ephemera_project }
      else
        format.html { render :edit }
        format.json { render json: @ephemera_project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ephemera_projects/1
  # DELETE /ephemera_projects/1.json
  def destroy
    @ephemera_project.destroy
    respond_to do |format|
      format.html { redirect_to ephemera_projects_url, notice: 'Ephemera project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_ephemera_project
      @ephemera_project = EphemeraProject.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ephemera_project_params
      params.require(:ephemera_project).permit(:name)
    end
end

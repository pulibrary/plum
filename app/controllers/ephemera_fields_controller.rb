class EphemeraFieldsController < ApplicationController
  before_action :set_ephemera_field, only: [:show, :edit, :update, :destroy]

  # GET /ephemera_fields
  # GET /ephemera_fields.json
  def index
    @ephemera_fields = EphemeraField.all
  end

  # GET /ephemera_fields/1
  # GET /ephemera_fields/1.json
  def show
  end

  # GET /ephemera_fields/new
  def new
    @ephemera_field = EphemeraField.new
  end

  # GET /ephemera_fields/1/edit
  def edit
  end

  # POST /ephemera_fields
  # POST /ephemera_fields.json
  def create
    @ephemera_field = EphemeraField.new(ephemera_field_params)

    respond_to do |format|
      if @ephemera_field.save
        format.html { redirect_to @ephemera_field, notice: 'Ephemera field was successfully created.' }
        format.json { render :show, status: :created, location: @ephemera_field }
      else
        format.html { render :new }
        format.json { render json: @ephemera_field.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ephemera_fields/1
  # PATCH/PUT /ephemera_fields/1.json
  def update
    respond_to do |format|
      if @ephemera_field.update(ephemera_field_params)
        format.html { redirect_to @ephemera_field, notice: 'Ephemera field was successfully updated.' }
        format.json { render :show, status: :ok, location: @ephemera_field }
      else
        format.html { render :edit }
        format.json { render json: @ephemera_field.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ephemera_fields/1
  # DELETE /ephemera_fields/1.json
  def destroy
    @ephemera_field.destroy
    respond_to do |format|
      format.html { redirect_to ephemera_fields_url, notice: 'Ephemera field was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ephemera_field
      @ephemera_field = EphemeraField.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ephemera_field_params
      params.require(:ephemera_field).permit(:name, :ephemera_project_id, :vocabulary_id)
    end
end

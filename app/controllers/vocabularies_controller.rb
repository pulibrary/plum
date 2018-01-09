# frozen_string_literal: true
class VocabulariesController < ApplicationController
  include ServesLinkedData

  before_action :set_vocabulary, only: [:show, :edit, :update, :destroy]
  authorize_resource only: [:new, :edit, :create, :update, :destroy]

  # GET /vocabularies
  # GET /vocabularies.json
  def index
    @vocabularies = Vocabulary.where(parent: nil).order(:label)
  end

  # GET /vocabularies/1
  # GET /vocabularies/1.json
  def show
    respond_to do |wants|
      wants.html
      wants.json
      wants.jsonld { render body: export_as_jsonld, content_type: 'application/ld+json' }
      wants.nt { render body: export_as_nt, content_type: 'application/n-triples' }
      wants.ttl { render body: export_as_ttl, content_type: 'text/turtle' }
    end
  end

  # GET /vocabularies/new
  def new
    @vocabulary = Vocabulary.new
    @parent_id = params[:parent_id]
  end

  # GET /vocabularies/1/edit
  def edit
    @parent_id = @vocabulary.parent.id if @vocabulary.parent
  end

  # POST /vocabularies
  # POST /vocabularies.json
  def create
    @vocabulary = Vocabulary.new(vocabulary_params)

    respond_to do |format|
      if @vocabulary.save
        format.html { redirect_to @vocabulary, notice: 'Vocabulary was successfully created.' }
        format.json { render :show, status: :created, location: @vocabulary }
      else
        format.html { render :new }
        format.json { render json: @vocabulary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vocabularies/1
  # PATCH/PUT /vocabularies/1.json
  def update
    respond_to do |format|
      if @vocabulary.update(vocabulary_params)
        format.html { redirect_to @vocabulary, notice: 'Vocabulary was successfully updated.' }
        format.json { render :show, status: :ok, location: @vocabulary }
      else
        format.html { render :edit }
        format.json { render json: @vocabulary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vocabularies/1
  # DELETE /vocabularies/1.json
  def destroy
    @vocabulary.destroy
    respond_to do |format|
      format.html { redirect_to vocabularies_url, notice: 'Vocabulary was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_vocabulary
      @vocabulary = Vocabulary.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vocabulary_params
      params.require(:vocabulary).permit(:label, :parent_id)
    end

    def export_as_jsonld
      {
        '@context': 'https://bibdata.princeton.edu/context.json',
        '@id': vocabulary_url(@vocabulary, locale: nil),
        '@type': 'skos:ConceptScheme',
        pref_label: @vocabulary.label
      }.to_json
    end
end

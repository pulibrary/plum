class VocabularyTermsController < ApplicationController
  before_action :set_vocabulary_term, only: [:show, :edit, :update, :destroy]
  authorize_resource only: [:new, :edit, :create, :update, :destroy]

  # GET /vocabulary_terms
  # GET /vocabulary_terms.json
  def index
    @vocabulary_terms = VocabularyTerm.all
  end

  # GET /vocabulary_terms/1
  # GET /vocabulary_terms/1.json
  def show
  end

  # GET /vocabulary_terms/new
  def new
    @vocabulary_term = VocabularyTerm.new
    @vocabulary_id = params[:vocabulary_id]
    @vocabulary_collection_id = params[:vocabulary_collection_id]
  end

  # GET /vocabulary_terms/1/edit
  def edit
  end

  # POST /vocabulary_terms
  # POST /vocabulary_terms.json
  def create
    @vocabulary_term = VocabularyTerm.new(vocabulary_term_params)

    respond_to do |format|
      if @vocabulary_term.save
        format.html { redirect_to @vocabulary_term, notice: 'Vocabulary term was successfully created.' }
        format.json { render :show, status: :created, location: @vocabulary_term }
      else
        format.html { render :new }
        format.json { render json: @vocabulary_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vocabulary_terms/1
  # PATCH/PUT /vocabulary_terms/1.json
  def update
    respond_to do |format|
      if @vocabulary_term.update(vocabulary_term_params)
        format.html { redirect_to @vocabulary_term, notice: 'Vocabulary term was successfully updated.' }
        format.json { render :show, status: :ok, location: @vocabulary_term }
      else
        format.html { render :edit }
        format.json { render json: @vocabulary_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vocabulary_terms/1
  # DELETE /vocabulary_terms/1.json
  def destroy
    @vocabulary_term.destroy
    respond_to do |format|
      format.html { redirect_to vocabulary_terms_url, notice: 'Vocabulary term was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_vocabulary_term
      @vocabulary_term = VocabularyTerm.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vocabulary_term_params
      params.require(:vocabulary_term).permit(:label, :uri, :code, :tgm_label, :lcsh_label, :vocabulary_id, :vocabulary_collection_id)
    end
end

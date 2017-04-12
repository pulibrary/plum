class VocabularyCollectionsController < ApplicationController
  before_action :set_vocabulary_collection, only: [:show, :edit, :update, :destroy]
  authorize_resource only: [:new, :edit, :create, :update, :destroy]

  # GET /vocabulary_collections
  # GET /vocabulary_collections.json
  def index
    @vocabulary_collections = VocabularyCollection.order(:label)
  end

  # GET /vocabulary_collections/1
  # GET /vocabulary_collections/1.json
  def show
  end

  # GET /vocabulary_collections/new
  def new
    @vocabulary_collection = VocabularyCollection.new
    @vocabulary_id = params[:vocabulary_id]
  end

  # GET /vocabulary_collections/1/edit
  def edit
  end

  # POST /vocabulary_collections
  # POST /vocabulary_collections.json
  def create
    @vocabulary_collection = VocabularyCollection.new(vocabulary_collection_params)

    respond_to do |format|
      if @vocabulary_collection.save
        format.html { redirect_to @vocabulary_collection, notice: 'Vocabulary collection was successfully created.' }
        format.json { render :show, status: :created, location: @vocabulary_collection }
      else
        format.html { render :new }
        format.json { render json: @vocabulary_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vocabulary_collections/1
  # PATCH/PUT /vocabulary_collections/1.json
  def update
    respond_to do |format|
      if @vocabulary_collection.update(vocabulary_collection_params)
        format.html { redirect_to @vocabulary_collection, notice: 'Vocabulary collection was successfully updated.' }
        format.json { render :show, status: :ok, location: @vocabulary_collection }
      else
        format.html { render :edit }
        format.json { render json: @vocabulary_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vocabulary_collections/1
  # DELETE /vocabulary_collections/1.json
  def destroy
    @vocabulary_collection.destroy
    respond_to do |format|
      format.html { redirect_to vocabulary_collections_url, notice: 'Vocabulary collection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_vocabulary_collection
      @vocabulary_collection = VocabularyCollection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vocabulary_collection_params
      params.require(:vocabulary_collection).permit(:label, :vocabulary_id)
    end
end

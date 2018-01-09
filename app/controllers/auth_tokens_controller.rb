# frozen_string_literal: true
class AuthTokensController < ApplicationController
  before_action :set_auth_token, only: [:show, :edit, :update, :destroy]
  authorize_resource only: [:new, :edit, :create, :update, :destroy]

  # GET /auth_tokens
  # GET /auth_tokens.json
  def index
    @auth_tokens = AuthToken.all
  end

  # GET /auth_tokens/1
  # GET /auth_tokens/1.json
  def show; end

  # GET /auth_tokens/new
  def new
    @auth_token = AuthToken.new
  end

  # GET /auth_tokens/1/edit
  def edit; end

  # POST /auth_tokens
  # POST /auth_tokens.json
  def create
    @auth_token = AuthToken.new(auth_token_params)

    respond_to do |format|
      @auth_token.save
      format.html { redirect_to @auth_token, notice: 'Auth token was successfully created.' }
      format.json { render :show, status: :created, location: @auth_token }
    end
  end

  # PATCH/PUT /auth_tokens/1
  # PATCH/PUT /auth_tokens/1.json
  def update
    respond_to do |format|
      @auth_token.update(auth_token_params)
      format.html { redirect_to @auth_token, notice: 'Auth token was successfully updated.' }
      format.json { render :show, status: :ok, location: @auth_token }
    end
  end

  # DELETE /auth_tokens/1
  # DELETE /auth_tokens/1.json
  def destroy
    @auth_token.destroy
    respond_to do |format|
      format.html { redirect_to auth_tokens_url, notice: 'Auth token was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_auth_token
      @auth_token = AuthToken.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def auth_token_params
      params.require(:auth_token).permit(:label, groups: [])
    end
end

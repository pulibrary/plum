class TokensController < ApplicationController
  def index
    authorize! :token, ScannedResource.new
    token = TokenService.new_token(encryption_key, current_user, expires)
    token_response = { accessToken: token, tokenType: 'Bearer', expiresIn: expires }
    render json: token_response
  end

  private

    def encryption_key
      Rails.application.secrets.secret_key_base
    end

    def expires
      @expires ||= (Plum.config[:token_expiration] || 3600)
    end
end

class ProfilesController < ApplicationController
  def show
    # mostra algumas informações do usuário da requisição
    # se ele for válido, caso contrário retorna um json
    # sem informações do usuário da requisição
    @user = usuario_request
    if @user.present? and request_autorizada?
      render json: {
        "user": {
          name:  @user.name,
          write: @user.allow_write,
          admin: @user.admin
        },
        token: token_jwt
      }
    else
      render json: {"user": nil, token: nil}
    end
  end
end

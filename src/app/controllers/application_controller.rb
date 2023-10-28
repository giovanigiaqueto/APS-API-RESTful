class ApplicationController < ActionController::API
  include Auth::Http
  include Auth::Jwt

  rescue_from ActiveRecord::RecordNotFound, with: :recurso_nao_encontrado
  rescue_from ActionController::ParameterMissing, with: :parametros_faltantes
  rescue_from Auth::Unauthorized, with: :nao_autorizado

  def recurso_nao_encontrado
    erro_request("Not Found", "resource not found", :not_found)
  end

  def nao_autorizado
    request_nao_autorizada("authentication required")
  end

  def parametros_faltantes
    request_invalida("missing parameters")
  end
end


class ApplicationController < ActionController::API
  include Auth::Http
  include Auth::Jwt

  rescue_from ActiveRecord::RecordNotFound, with: :recurso_nao_encontrado
  rescue_from ActionController::ParameterMissing, with: :parametros_faltantes
  rescue_from Auth::Unauthorized, with: :nao_autorizado
  rescue_from Auth::Forbidden, with: :nao_permitido

  rescue_from Auth::WritePermissionRequired do |exception|
    nao_permitido(faltando: :escrita)
  end

  rescue_from Auth::AdminPermissionRequired do |exception|
    nao_permitido(faltando: :admin)
  end

  def recurso_nao_encontrado
    erro_request("Not Found", "resource not found", :not_found)
  end

  def nao_autorizado
    # a requisição não foi autorizada por falha na autenticação correta
    request_nao_autorizada("authentication required")
  end

  def nao_permitido(faltando: nil)
    # a requisição não foi permitida por falta de privilégios ao acessar
    # um recurso da API, mesmo que a requisição tenha sido feita de forma
    # autenticada com um token JWT válido
    case faltando
    when :admin
      request_nao_permitida("missing admin privileges")
    when :escrita
      request_nao_permitida("missing write privileges")
    else
      request_nao_permitida("missing required privileges")
    end
  end

  def parametros_faltantes
    request_invalida("missing parameters")
  end
end


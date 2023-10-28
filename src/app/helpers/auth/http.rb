module Auth::Http
  def header_auth
    # Leitura do campo HTTP 'Authorization' no header
    if auth = request.headers['Authorization']
      auth_type, token = auth.split(' ')
      unless auth_type.empty? or token.nil? or token.empty?
        return {type: auth_type, value: token}
      end
    end
  end

  def request_invalida(motivo)
    raise ArgumentError, "missing response reason argument 'motivo'" unless motivo.present?
    render(
      json: {
        "text":   "Bad Request",
        "reason": motivo
      }
    )
  end

  def request_nao_autorizada(motivo)
    raise ArgumentError, "missing response reason argument 'motivo'" unless motivo.present?
    render(
      json: {
        "text":   "Unauthorized",
        "reason": motivo
      },
      status: :unauthorized
    )
  end
end

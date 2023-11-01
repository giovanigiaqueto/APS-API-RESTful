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

  def resposta_request(texto, motivo = nil, status: :ok)
    # gera uma resposta json contendo o texto, e opcionalmente um motivo
    # para detalhar a resposta, assim como um código de status HTTP
    #
    # gera ArgumentError caso o texto seja "nil" ou vazio

    raise ArgumentError, "missing 'texto' field for response" if texto.blank?

    if motivo.present? and motivo.respond_to?(:to_s)
      render json: {"text": texto, "reason": motivo}, status: status
    else
      render json: {"text": texto}, status: status
    end
  end

  def erro_request(texto, motivo, status)
    # gera uma resposta json contendo um texto e motivo que descreva
    # o erro, assim como um código de status HTTP associado
    #
    # gera ArgumentError caso o texto ou o motivo sejam "nil" ou vazio
    # gera TypeError caso o status HTTP não seja um símbolo (Symbol)

    raise ArgumentError, "missing 'motivo' field for response" if motivo.blank?

    if status.respond_to?(:to_sym)
      status = status.to_sym unless status.is_a?(Symbol)
    else
      raise TypeError, "no implict conversion from #{status.class} into Symbol"
    end

    resposta_request(texto, motivo, status: status)
  end

  def request_invalida(motivo)
    # resposta relacionada a uma request mal formada
    erro_request("Bad Request", motivo, :bad_request)
  end

  def request_nao_autorizada(motivo)
    # resposta relacionada a uma request não autorizada por um token JWT
    erro_request("Unauthorized", motivo, :unauthorized)
  end

  def request_nao_permitida(motivo)
    # resposta relacionada a uma request autorizada por um token JWT,
    # mas que não tem privilégios suficientes para acessar um recurso
    erro_request("Forbidden", motivo, :forbidden)
  end

  def internal_server_error(motivo = nil)
    # resposta relacionada a um erro interno do servidor ao processar a request
    motivo = "unknown cause" if motivo.blank?
    erro_request("Internal Server Error", motivo, :internal_server_error)
  end
end

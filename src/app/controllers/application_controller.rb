class ApplicationController < ActionController::API
  def header_auth
    # Leitura do campo HTTP 'Authorization' no header
    if auth = request.headers['Authorization']
      auth_type, token = auth.split(' ')
      unless auth_type.empty? or token.nil? or token.empty?
        return {type: auth_type, value: token}
      end
    end
  end

  def codificar_jwt(payload)
    # codifica o token JWT com a chave privada do serviço
    segredos      = Rails.application.credentials
    chave_privada = segredos.jwt.chave_privada
    algoritimo    = segredos.jwt.algoritimo

    if chave_privada.nil? or chave_privada.empty?
      logger.fatal "Missing 'jwt.chave_privada' in credentials.yml.enc file"
    end

    case algoritimo
    when nil
      logger.fatal "Missing 'jwt.algoritimo' in credentials.yml.enc file"
    when "RS256", "RS384", "RS512"
      # RSA com SHA-256, SHA-384 ou SHA-512 como algorítimo de hash
      chave_rsa = OpenSSL::PKey::RSA.new(chave_privada)
      JWT::encode(payload, chave_rsa, algorithm=algoritimo, header_fields={ typ: 'JWT' })
    else
      logger.fatal "Usupported JWT signing algorithm: '#{algoritimo}'"
    end
  end

  def decodificar_jwt(token, hash: false)
    # decodifica o token JWT com a chave pública do serviço,
    # retornando o payload e header como Array, ou Hash
    # se a opção :hash for true
    segredos      = Rails.application.credentials
    chave_publica = segredos.jwt.chave_publica
    algoritimo    = segredos.jwt.algoritimo

    if chave_publica.nil? or chave_publica.empty?
      logger.fatal "Missing 'jwt.chave_publica' in credentials.yml.enc file"
    end

    case algoritimo
    when nil
      logger.fatal "Missing 'jwt.algoritimo' in credentials.yml.enc file"
    when "RS256", "RS384", "RS512"
      # RSA com SHA-256, SHA-384 ou SHA-512 como algorítimo de hash
      chave_rsa = OpenSSL::PKey::RSA.new(chave_publica)
      payload, header = JWT::decode(token, chave_rsa, true, { algorithm: algoritimo })
      if header["typ"] != 'JWT'
        logger.debug "Token is not a JWT: payload=#{payload}, header=#{header}"
      else
        logger.debug "JWT: payload=#{payload}, header=#{header}"
        return {payload: payload, header: header} if hash
        return payload, header
      end
    else
      logger.fatal "Usupported JWT signing algorithm: '#{algoritimo}'"
    end
  end

  def jwt_decodificado(hash: false)
    # decodifica e retorna o token JWT caso ele esteja
    # presente no campo 'Authorization' do request HTTP
    #
    # a opção :hash controla se o token é retornado como
    # um par payload + header ou como um Hash
    if auth = header_auth
      decodificar_jwt(auth[:value], hash: hash) unless auth[:type] != "Bearer"
    end
  rescue JWT::DecodeError
    nil
  end

  def token_jwt
    # retorna o token JWT da requisição, caso existir
    @token ||= jwt_decodificado(hash: true)
  end

  def usuario_request
    # retorna o usuário que fez a request com base no token JWT,
    # caso ele existir e o token não for inválido
    if token = token_jwt
      id        = token[:payload]['user_id']
      timestamp = token[:payload]['timestamp']

      # descarta o token em caso de campos faltantes
      if id.nil?
        logger.debug "Ignored JWT without 'user_id' field: #{token}"
        return nil
      elsif timestamp.nil?
        logger.debug "Ignored JWT without 'timestamp' field: #{token}"
        return nil
      end

      @user = User.find_by(id: id)
      return @user unless block_given?
      yield  @user
    end
  end

  def jwt_antigo?
    # verifica se o token JWT da requisição contém uma marca de tempo
    # (timestamp) menor que a marca de tempo da última alteração do registro
    # do usuário, impendendo que tokens sejam usados após alteração do cadastro
    #
    # AVISO: uma margem de um segundo (1s) é tolerada
    usuario = usuario_request
    token   = token_jwt
    return if usuario.nil? or token.nil?
    t0 = Time.parse(token['timestamp'])
    t1 = usuario.updated_at.to_datetime
    (t1 - t0) <= 1
  end

  def request_autorizada?
    # verifica se a request foi autorizada através de um token JWT válido
    unless usuario_request.nil? or jwt_antigo?
      true
    else
      false
    end
  end

  def autorizar_request!
    # verifica se a request for autorizada através de um token JWT válido,
    # respondendo com "401: Unauthorized" caso a request não tenha um JWT
    # ou o token seja mais antigo que o marca de tempo da ultima alteração
    # do cadastro de usuário que fez a request
    if usuario_request.nil?
      render(
        json: {
          "text":   "Unauthorized",
          "reason": "missing or invalid JWT token"
        },
        status: :unauthorized
      )
    elsif jwt_antigo?
      render(
        json: {
          "text":   "Unauthorized",
          "reason": "expired timestamp"
        },
        status: :unauthorized
      )
    else
      return true
    end
    false
  end

  def escrita_permitida?
    # verifica se o usuário da request tem permissão de alterar
    # os dados do API com os métodos POST, PUT, PATCH ou DELETE
    usuario_request do |usuario|
      (usuario.allow_write? or usuario.admin?)
    end
  end

  def permissao_admin?
    # verifica se o usuário da request tem permissão de admin
    # para alterar cadastros de usuário
    usuario_request do |usuario|
      usuario.admin?
    end
  end
end


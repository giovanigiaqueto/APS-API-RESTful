module Auth
end

class Auth::Unauthorized < Exception
  # tipo de exceção para requests não autorizadas
end

class Auth::Forbidden < Auth::Unauthorized
  # tipo de exceção para requests autorizadas,
  # mas com privilégios insuficientes
end

class Auth::PermissionRequired < Auth::Forbidden
  # tipo de exceção para requests autorizadas pelo sistema
  # de autenticação, mas que não foram permitidas pela falta
  # de privilégios do usuário que fez a request
end

class Auth::WritePermissionRequired < Auth::PermissionRequired
  # tipo de exceção para requests autorizadas pelo sistema
  # de autenticação, mas que não foram permitidas pela falta
  # de privilégios de escrita do usuário que fez a request
end

class Auth::AdminPermissionRequired < Auth::PermissionRequired
  # tipo de exceção para requests autorizadas pelo sistema
  # de autenticação, mas que não foram permitidas pela falta
  # de privilégios de admin do usuário que fez a request
end

class Auth::MissingJwt < Auth::Unauthorized
  # tipo de exceção para requests não autorizadas
  # por não terem um token JWT
end

class Auth::InvalidJwt < Auth::Unauthorized
  # tipo de exceção para requests não autorizadas
  # pelo token JWT fornecido ser inválido
end

class Auth::ExpiredJwt < Auth::Unauthorized
  # tipo de exceção para requests não autorizadas
  # pelo token JWT fornecido estar expirado
end

module Auth
end

class Auth::Unauthorized < Exception
  # tipo de exceção para requests não autorizadas
end

class Auth::PermissionRequired < Auth::Unauthorized
  # tipo de exceção para requests não autorizadas
  # causada pelo usuário não ter permissões suficientes
end

class Auth::WritePermissionRequired < Auth::PermissionRequired
  # tipo de exceção para requests não autorizadas
  # pela falta de permissões de escrita do usuário
end

class Auth::AdminPermissionRequired < Auth::PermissionRequired
  # tipo de exceção para requests não autorizadas
  # pela falta de permissões de admin do usuário
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

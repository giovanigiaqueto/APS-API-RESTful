class ApplicationController < ActionController::API
  include Auth::Http
  include Auth::Jwt
end


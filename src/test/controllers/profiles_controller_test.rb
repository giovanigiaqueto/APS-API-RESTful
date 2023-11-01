require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get show (unauthenticated)" do
    get profiles_show_url
    assert_response :ok
    assert(@response.content_type.include?("application/json"))

    json = JSON.parse(@response.body)
    assert_nil(json["user"])
    assert_nil(json["token"])
  end

  test "should get show (unknown token)" do
    app   = ApplicationController.new
    id    = gerar_id_disponivel(User)
    token = app.codificar_jwt({
      "user_id":   id,
      "timestamp": Time.at(0).utc
    })

    get profiles_show_url,
      headers: { Authorization: "Bearer #{token}" }
    assert_response :ok
    assert(@response.content_type.include?("application/json"))

    json = JSON.parse(@response.body)
    assert_nil(json["user"])
    assert_nil(json["token"])
  end

  test "should get show (invalid token)" do
    usuario = users(:admin)

    app = ApplicationController.new
    token = app.codificar_jwt({
      "user_id":   usuario.id,
      "timestamp": Time.at(0).utc
    })

    get profiles_show_url,
      headers: { Authorization: "Bearer #{token}" }
    assert_response :ok
    assert(@response.content_type.include?("application/json"))

    json = JSON.parse(@response.body)
    assert_nil(json["user"])
    assert_nil(json["token"])
  end

  test "should get show (authenticated 1/3)" do
    get profiles_show_url,
      headers: { Authorization: "Bearer #{jwt_simples}" }
    assert_response :ok
    assert(@response.content_type.include?("application/json"))

    json = JSON.parse(@response.body)
    usuario = json["user"]
    token   = json["token"]
    assert_not_nil(usuario)
    assert_not_nil(token)

    # verificação do usuário da resposta
    usuario_request = users(:simples)
    assert_equal(usuario["name"],  usuario_request.name)
    assert_equal(usuario["write"], false)
    assert_equal(usuario["admin"], false)

    # verificação do token da resposta
    token_request   = jwt_simples
    payload, header = application.decodificar_jwt(token_request)
    assert_not_nil(token["payload"])
    assert_not_nil(token["header"])
    assert_equal(token["payload"], payload)
    assert_equal(token["header"],  header)
    assert_equal(token["header"]["typ"], "JWT")
  end

  test "should get show (authenticated 2/3)" do
    get profiles_show_url,
      headers: { Authorization: "Bearer #{jwt_escrita}" }
    assert_response :ok
    assert(@response.content_type.include?("application/json"))

    json = JSON.parse(@response.body)
    usuario = json["user"]
    token   = json["token"]
    assert_not_nil(usuario)
    assert_not_nil(token)

    # verificação do usuário da resposta
    usuario_request = users(:escrita)
    assert_equal(usuario["name"],  usuario_request.name)
    assert_equal(usuario["write"], true)
    assert_equal(usuario["admin"], false)

    # verificação do token da resposta
    token_request   = jwt_escrita
    payload, header = application.decodificar_jwt(token_request)
    assert_not_nil(token["payload"])
    assert_not_nil(token["header"])
    assert_equal(token["payload"], payload)
    assert_equal(token["header"],  header)
    assert_equal(token["header"]["typ"], "JWT")
  end

  test "should get show (authenticated 3/3)" do
    get profiles_show_url,
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :ok
    assert(@response.content_type.include?("application/json"))

    json = JSON.parse(@response.body)
    usuario = json["user"]
    token   = json["token"]
    assert_not_nil(usuario)
    assert_not_nil(token)

    # verificação do usuário da resposta
    usuario_request = users(:admin)
    assert_equal(usuario["name"],  usuario_request.name)
    assert_equal(usuario["write"], true)
    assert_equal(usuario["admin"], true)

    # verificação do token da resposta
    token_request   = jwt_admin
    payload, header = application.decodificar_jwt(token_request)
    assert_not_nil(token["payload"])
    assert_not_nil(token["header"])
    assert_equal(token["payload"], payload)
    assert_equal(token["header"],  header)
    assert_equal(token["header"]["typ"], "JWT")
  end
end

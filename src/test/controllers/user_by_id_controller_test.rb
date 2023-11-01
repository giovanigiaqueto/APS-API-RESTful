require "test_helper"

class UserByIdControllerTest < ActionDispatch::IntegrationTest
   def cabecalho(tipo = :admin)
    case tipo
    when :admin
      { Authorization: "Bearer #{jwt_admin}" }
    when :escrita
      { Authorization: "Bearer #{jwt_escrita}" }
    when :simples
      { Authorization: "Bearer #{jwt_simples}" }
    else
      { Authorization: "Bearer #{jwt_admin}" }
    end
  end

  test "should get show" do
    usuario = users(:one)
    get user_by_id_show_url(id: usuario.id),
      headers: cabecalho(:admin)
    assert_response :success
  end

  test "should not get show (unauthorized)" do
    usuario = users(:two)
    get user_by_id_show_url(id: usuario.id)
    assert_response :unauthorized
  end

  test "should not get show (forbidden)" do
    usuario = users(:one)
    get user_by_id_show_url(id: usuario.id),
      headers: cabecalho(:escrita)
    assert_response :forbidden
  end

  test "should not get show (invalid parameter)" do
    get user_by_id_show_url(id: "abc"),
      headers: cabecalho(:admin)
    assert_response :bad_request
  end

  test "should not get show (not found)" do
    id = gerar_id_disponivel(User, :id)
    get user_by_id_show_url(id: id),
      headers: cabecalho(:admin)
    assert_response :not_found
  end

  test "should put update" do
    usuario = users(:two)
    put user_by_id_update_url(id: usuario.id),
      params: {
        name:  "Novo Nome de Usuário",
        write: '1',
        admin: '0'
      },
      headers: cabecalho(:admin)
    assert_response :ok

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name, "Novo Nome de Usuário")
    assert(usuario_banco.allow_write?)
    assert_not(usuario_banco.admin?)
  end

  test "should not put update (unauthorized)" do
    usuario = users(:one)
    put user_by_id_update_url(id: usuario.id),
      params: {
        name:  "Novo Nome de Usuário",
        write: '1',
        admin: '0'
      }
    assert_response :unauthorized

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should not put update (forbidden)" do
    usuario = users(:two)
    put user_by_id_update_url(id: usuario.id),
      params: {
        name:  "Novo Nome de Usuário",
        write: '1',
        admin: '0'
      },
      headers: cabecalho(:escrita)
    assert_response :forbidden

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should not put update (missing parameters 1/3)" do
    usuario = users(:one)
    put user_by_id_update_url(id: usuario.id),
      params: {
        write: '1',
        admin: '0'
      },
      headers: cabecalho(:admin)
    assert_response :bad_request

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should not put update (missing parameters 2/3)" do
    usuario = users(:two)
    put user_by_id_update_url(id: usuario.id),
      params: {
        name:  "Novo Nome de Usuário",
        admin: '0'
      },
      headers: cabecalho(:admin)
    assert_response :bad_request

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should not put update (missing parameters 3/3)" do
    usuario = users(:one)
    put user_by_id_update_url(id: usuario.id),
      params: {
        name:  "Novo Nome de Usuário",
        write: '1'
      },
      headers: cabecalho(:admin)
    assert_response :bad_request

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should not put update (invalid parameters 1/2)" do
    usuario = users(:two)
    put user_by_id_update_url(id: usuario.id),
      params: {
        name:  "Novo Nome de Usuário",
        write: 'abc',
        admin: '0'
      },
      headers: cabecalho(:admin)
    assert_response :bad_request

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should not put update (invalid parameters 2/2)" do
    usuario = users(:one)
    put user_by_id_update_url(id: usuario.id),
      params: {
        name:  "Novo Nome de Usuário",
        write: '0',
        admin: 'abc'
      },
      headers: cabecalho(:admin)
    assert_response :bad_request

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should not put update (not found)" do
    id = gerar_id_disponivel(User, :id)
    put user_by_id_update_url(id: id),
      params: {
        name:  "Novo Nome de Usuário",
        write: '1',
        admin: '0'
      },
      headers: cabecalho(:admin)
    assert_response :not_found
    assert_nil(User.find_by(id: id))
  end

  test "should patch update" do
    usuario = users(:two)
    patch user_by_id_update_url(id: usuario.id),
      params: {
        name:  "Novo Nome de Usuário",
        write: '1',
        admin: '0'
      },
      headers: cabecalho(:admin)
    assert_response :ok

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name, "Novo Nome de Usuário")
    assert(usuario_banco.allow_write?)
    assert_not(usuario_banco.admin?)
  end

  test "should patch update (partial 1/3)" do
    usuario = users(:two)
    patch user_by_id_update_url(id: usuario.id),
      params: { name:  "Novo Nome de Usuário" },
      headers: cabecalho(:admin)
    assert_response :success

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        "Novo Nome de Usuário")
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should patch update (partial 2/3)" do
    usuario = users(:one)
    patch user_by_id_update_url(id: usuario.id),
      params: { write: usuario.allow_write ? '0' : '1' },
      headers: cabecalho(:admin)
    assert_response :success

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, (not usuario.allow_write))
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should patch update (partial 3/3)" do
    usuario = users(:two)
    patch user_by_id_update_url(id: usuario.id),
      params: { admin: usuario.admin? ? '0' : '1' },
      headers: cabecalho(:admin)
    assert_response :success

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name, usuario.name)
    if usuario.admin?
      assert_equal(usuario_banco.allow_write, usuario.allow_write)
      assert_equal(usuario_banco.admin,       false)
    else
      # NOTE: allow_write é setado para 'true' antes do registro
      #       ser salvo no banco de dados caso admin seja 'true'
      assert_equal(usuario_banco.allow_write, true)
      assert_equal(usuario_banco.admin,       true)
    end
  end

  test "should not patch update (unauthorized)" do
    usuario = users(:one)
    patch user_by_id_update_url(id: usuario.id),
      params: {
        name:  "Novo Nome de Usuário",
        write: '1',
        admin: '0'
      }
    assert_response :unauthorized

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should not patch update (forbidden)" do
    usuario = users(:two)
    patch user_by_id_update_url(id: usuario.id),
      params: {
        name:  "Novo Nome de Usuário",
        write: '1',
        admin: '0'
      },
      headers: cabecalho(:escrita)
    assert_response :forbidden

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should not patch update (invalid parameters 1/2)" do
    usuario = users(:two)
    patch user_by_id_update_url(id: usuario.id),
      params: {
        name:  "Novo Nome de Usuário",
        write: 'abc',
        admin: '0'
      },
      headers: cabecalho(:admin)
    assert_response :bad_request

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should not patch update (invalid parameters 2/2)" do
    usuario = users(:one)
    patch user_by_id_update_url(id: usuario.id),
      params: {
        name:  "Novo Nome de Usuário",
        write: '0',
        admin: 'abc'
      },
      headers: cabecalho(:admin)
    assert_response :bad_request

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should not patch update (not found)" do
    id = gerar_id_disponivel(User, :id)
    patch user_by_id_update_url(id: id),
      params: {
        name:  "Novo Nome de Usuário",
        write: '1',
        admin: '0'
      },
      headers: cabecalho(:admin)
    assert_response :not_found
    assert_nil(User.find_by(id: id))
  end

  test "should delete destroy" do
    usuario = users(:one)
    delete user_by_id_destroy_url(id: usuario.id),
      headers: cabecalho(:admin)
    assert_response :ok
    assert_nil(User.find_by(id: usuario.id))
  end

  test "should not delete destroy (unauthorized)" do
    usuario = users(:one)
    delete user_by_id_destroy_url(id: usuario.id)
    assert_response :unauthorized
    assert_not_nil(User.find_by(id: usuario.id))
  end

  test "should not delete destroy (forbidden)" do
    usuario = users(:one)
    delete user_by_id_destroy_url(id: usuario.id),
      headers: cabecalho(:escrita)
    assert_response :forbidden
    assert_not_nil(User.find_by(id: usuario.id))
  end

  test "should not delete destroy (invalid parameters)" do
    usuario = users(:two)
    patch user_by_id_destroy_url(id: "abc"),
      headers: cabecalho(:admin)
    assert_response :bad_request

    usuario_banco = User.find_by(id: usuario.id)
    assert_not_nil(usuario_banco)

    assert_equal(usuario_banco.name,        usuario.name)
    assert_equal(usuario_banco.allow_write, usuario.allow_write)
    assert_equal(usuario_banco.admin,       usuario.admin)
  end

  test "should not delete destroy (not found)" do
    id = gerar_id_disponivel(User, :id)
    delete user_by_id_destroy_url(id: id),
      headers: cabecalho(:admin)
    assert_response :not_found
    assert_nil(User.find_by(id: id))
  end
end

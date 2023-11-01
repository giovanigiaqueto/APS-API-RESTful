require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get users_index_url, headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :success
  end

  test "should not get index (unauthorized)" do
    get users_index_url
    assert_response :unauthorized
  end

  test "should not get index (forbidden)" do
    get users_index_url,
      headers: { Authorization: "Bearer #{jwt_escrita}" }
    assert_response :forbidden
  end

  test "should get show" do
    usuario = users(:two)
    get users_show_url(name: usuario.name),
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :success
  end

  test "should not get show (unauthorized)" do
    usuario = users(:one)
    get users_show_url(name: usuario.name)
    assert_response :unauthorized
  end

  test "should not get show (forbidden)" do
    usuario = users(:one)
    get users_show_url(name: usuario.name),
      headers: { Authorization: "Bearer #{jwt_escrita}"}
    assert_response :forbidden
  end

  test "should post create" do
    post users_create_url,
      params: { name: "usuário novo", write: '0', admin: '0' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :created
    usuario = User.find_by(name: "usuário novo")
    assert_not_nil(usuario)
    assert_not(usuario.allow_write?)
    assert_not(usuario.admin?)
  end

  test "should post create (missing optional parameters 1/2)" do
    post users_create_url,
      params: { name: "New User", admin: '0' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :created
  end

  test "should post create (missing optional parameters 2/2)" do
    post users_create_url,
      params: { name: "New User", write: '0' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :created
  end

  test "should not post create (unauthorized)" do
    post users_create_url,
      params: { name: "New User", write: '0', admin: '0' }
    assert_response :unauthorized
  end

  test "should not post create (forbidden)" do
    post users_create_url,
      params: { name: "New User", write: '0', admin: '0' },
      headers: { Authorization: "Bearer #{jwt_escrita}"}
    assert_response :forbidden
  end

  test "should not post create (missing required parameters)" do
    post users_create_url,
      params: { write: '0', admin: '0' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :bad_request
  end

  test "should not post create (invalid parameters 1/2)" do
    post users_create_url,
      params: { name: "New User", write: 'abc', admin: '0' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :bad_request
  end

  test "should not post create (invalid parameters 2/2)" do
    post users_create_url,
      params: { name: "New User", write: '0', admin: 'abc' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :bad_request
  end

  test "should not post create (conflict)" do
    nome = users(:one).name
    post users_create_url,
      params: { name: nome, write: '0', admin: '0' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :conflict
  end

  test "should put update" do
    usuario = users(:two)
    put users_update_url(name: usuario.name),
      params: { write: '1', admin: '0' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :success

    usuario_banco = User.find_by(name: usuario.name)
    assert_not_nil(usuario_banco)
    assert_equal(usuario.id, usuario_banco.id)
    assert(usuario_banco.allow_write?)
    assert_not(usuario_banco.admin?)
  end

  test "should not put update (unauthorized)" do
    usuario = users(:one)
    put users_update_url(name: usuario.name),
      params: { write: '1', admin: '0' }
    assert_response :unauthorized

    usuario_banco = User.find_by(name: usuario.name)
    assert_not_nil(usuario_banco)
    assert_equal(usuario.id,          usuario_banco.id)
    assert_equal(usuario.allow_write, usuario.allow_write)
    assert_equal(usuario.admin,       usuario.admin)
  end

  test "should not put update (forbidden)" do
    usuario = users(:two)
    put users_update_url(name: usuario.name),
      params: { write: '1', admin: '0' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :success

    usuario_banco = User.find_by(name: usuario.name)
    assert_not_nil(usuario_banco)
    assert_equal(usuario.id,          usuario_banco.id)
    assert_equal(usuario.allow_write, usuario.allow_write)
    assert_equal(usuario.admin,       usuario.admin)
  end

  test "should not put update (missing parameters 1/2)" do
    usuario = users(:one)
    put users_update_url(name: usuario.name),
      params: { admin: '0' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :bad_request

    usuario_banco = User.find_by(name: usuario.name)
    assert_not_nil(usuario_banco)
    assert_equal(usuario.id,          usuario_banco.id)
    assert_equal(usuario.allow_write, usuario.allow_write)
    assert_equal(usuario.admin,       usuario.admin)
  end

  test "should not put update (missing parameters 2/2)" do
    usuario = users(:two)
    put users_update_url(name: usuario.name),
      params: { write: '1' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :bad_request

    usuario_banco = User.find_by(name: usuario.name)
    assert_not_nil(usuario_banco)
    assert_equal(usuario.id,          usuario_banco.id)
    assert_equal(usuario.allow_write, usuario.allow_write)
    assert_equal(usuario.admin,       usuario.admin)
  end

  test "should not put update (invalid parameters 1/2)" do
    usuario = users(:one)
    put users_update_url(name: usuario.name),
      params: { write: 'abc', admin: '0' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :bad_request

    usuario_banco = User.find_by(name: usuario.name)
    assert_not_nil(usuario_banco)
    assert_equal(usuario.id,          usuario_banco.id)
    assert_equal(usuario.allow_write, usuario.allow_write)
    assert_equal(usuario.admin,       usuario.admin)
  end

  test "should not put update (invalid parameters 2/2)" do
    usuario = users(:two)
    put users_update_url(name: usuario.name),
      params: { write: '1', admin: 'abc' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :bad_request

    usuario_banco = User.find_by(name: usuario.name)
    assert_not_nil(usuario_banco)
    assert_equal(usuario.id,          usuario_banco.id)
    assert_equal(usuario.allow_write, usuario.allow_write)
    assert_equal(usuario.admin,       usuario.admin)
  end

  test "should not put update (not found)" do
    nome = "Usuário Inexistente"
    put users_update_url(name: nome),
      params: { write: '1', admin: '0' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :not_found
    assert_nil(User.find_by(name: nome))
  end

  test "should patch update" do
    usuario = users(:one)
    patch users_update_url(name: usuario.name),
      params: { write: '1' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :success

    usuario_banco = User.find_by(name: usuario.name)
    assert_not_nil(usuario_banco)
    assert_equal(usuario.id,    usuario_banco.id)
    assert_equal(usuario.admin, usuario_banco.admin)
    assert(usuario_banco.allow_write?)
  end

  test "should not patch update (unauthorized)" do
    usuario = users(:two)
    patch users_update_url(name: usuario.name),
      params: { write: '1' }
    assert_response :unauthorized

    usuario_banco = User.find_by(name: usuario.name)
    assert_not_nil(usuario_banco)
    assert_equal(usuario.id,          usuario_banco.id)
    assert_equal(usuario.allow_write, usuario_banco.allow_write)
    assert_equal(usuario.admin,       usuario_banco.admin)
  end

  test "should not patch update (forbidden)" do
    usuario = users(:one)
    patch users_update_url(name: usuario.name),
      params: { admin: '1' },
      headers: { Authorization: "Bearer #{jwt_escrita}" }
    assert_response :forbidden

    usuario_banco = User.find_by(name: usuario.name)
    assert_not_nil(usuario_banco)
    assert_equal(usuario.id,          usuario_banco.id)
    assert_equal(usuario.allow_write, usuario_banco.allow_write)
    assert_equal(usuario.admin,       usuario_banco.admin)
  end

  test "should not patch update (invalid parameters 1/2)" do
    usuario = users(:two)
    patch users_update_url(name: usuario.name),
      params: { write: 'abc' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :bad_request

    usuario_banco = User.find_by(name: usuario.name)
    assert_not_nil(usuario_banco)
    assert_equal(usuario.id,          usuario_banco.id)
    assert_equal(usuario.allow_write, usuario.allow_write)
    assert_equal(usuario.admin,       usuario.admin)
  end

  test "should not patch update (invalid parameters 2/2)" do
    usuario = users(:one)
    patch users_update_url(name: usuario.name),
      params: { admin: 'abc' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :bad_request

    usuario_banco = User.find_by(name: usuario.name)
    assert_not_nil(usuario_banco)
    assert_equal(usuario.id,          usuario_banco.id)
    assert_equal(usuario.allow_write, usuario.allow_write)
    assert_equal(usuario.admin,       usuario.admin)
  end

  test "should not patch update (not found)" do
    nome = "Usuário Inexistente"
    put users_update_url(name: nome),
      params: { write: '1' },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :not_found
    assert_nil(User.find_by(name: nome))
  end

  test "should delete destroy" do
    usuario = users(:one)
    delete users_destroy_url(name: usuario.name),
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :success

    assert_nil(User.find_by(name: usuario.name))
    assert_nil(User.find_by(id: usuario.id))
  end

  test "should not delete destroy (unauthorized)" do
    usuario = users(:two)
    delete users_destroy_url(name: usuario.name)
    assert_response :unauthorized

    assert_not_nil(User.find_by(name: usuario.name))
    assert_not_nil(User.find_by(id: usuario.id))
  end

  test "should not delete destroy (forbidden)" do
    usuario = users(:one)
    delete users_destroy_url(name: usuario.name),
      headers: { Authorization: "Bearer #{jwt_escrita}" }
    assert_response :forbidden

    assert_not_nil(User.find_by(name: usuario.name))
    assert_not_nil(User.find_by(id: usuario.id))
  end

  test "should rename" do
    novo_nome = "Novo Nome de Usuário"
    usuario   = users(:one)
    post users_rename_url(name: usuario.name),
      params:  { value: novo_nome },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :ok
    assert_nil(User.find_by(name: usuario.name))
    assert_not_nil(User.find_by(name: novo_nome))
  end

  test "should not rename (unauthorized)" do
    novo_nome = "Novo Nome de Usuário"
    usuario   = users(:two)
    post users_rename_url(name: usuario.name),
      params: { value: novo_nome }
    assert_response :unauthorized
    assert_not_nil(User.find_by(name: usuario.name))
  end

  test "should not rename (forbidden)" do
    novo_nome = "Novo Nome de Usuário"
    usuario   = users(:one)
    post users_rename_url(name: usuario.name),
      params:  { value: novo_nome },
      headers: { Authorization: "Bearer #{jwt_escrita}" }
    assert_response :forbidden
    assert_not_nil(User.find_by(name: usuario.name))
  end

  test "should not rename (conflict)" do
    usuario_1 = users(:one)
    usuario_2 = users(:two)
    post users_rename_url(name: usuario_1.name),
      params:  { value: usuario_2.name },
      headers: { authorization: "Bearer #{jwt_admin}" }
    assert_response :conflict
    assert_not_nil(User.find_by(name: usuario_1.name))
  end

  test "should not rename (not found)" do
    nome_antigo = "Usuário Inexistente (antigo)"
    nome_novo   = "Usuário Inexistente (novo)"
    post users_rename_url(name: nome_antigo),
      params:  { value: nome_novo },
      headers: { Authorization: "Bearer #{jwt_admin}" }
    assert_response :not_found
    assert_nil(User.find_by(name: nome_antigo))
  end
end

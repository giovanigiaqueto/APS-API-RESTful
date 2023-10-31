require "test_helper"

class CountriesControllerTest < ActionDispatch::IntegrationTest
  def cabecalho(escrita: false)
    if escrita
      { Authorization: "Bearer #{jwt_escrita}" }
    else
      { Authorization: "Bearer #{jwt_simples}" }
    end
  end

  test "should get index" do
    get countries_index_url, headers: cabecalho
    assert_response :success
  end

  test "should not get index (unauthorized)" do
    get countries_index_url
    assert_response :unauthorized
  end

  test "should get show" do
    pais = countries(:one)
    get countries_show_url(name: pais.name), headers: cabecalho
    assert_response :success
  end

  test "should not get show (unauthorized)" do
    pais = countries(:two)
    get countries_show_url(name: pais.name)
    assert_response :unauthorized
  end

  test "should post create" do
    post countries_create_url,
      params: {
        name:             "Outro País 2",
        corruption_index: "70",
        annual_income:    "1000,20"
      },
      headers: cabecalho(escrita: true)
    assert_response :success

    pais = Country.find_by(name: "Outro País 2")
    assert_not_nil(pais)
    assert_equal(pais.corruption_index, 70)
    assert_equal(pais.annual_income, 1000.20)
  end

  test "should not post create (unauthorized)" do
    post countries_create_url,
      params: {
        name:             "Outro País 7",
        corruption_index: "27",
        annual_income:    "226,49"
      }
    assert_response :unauthorized
    assert_nil(Country.find_by(name: "Outro País 7"))
  end

  test "should not post create (forbidden)" do
    post countries_create_url,
      params: {
        name:             "Outro País 7",
        corruption_index: "27",
        annual_income:    "226,49"
      },
      headers: cabecalho(escrita: false)
    assert_response :forbidden
    assert_nil(Country.find_by(name: "Outro País 7"))
  end

  test "should not post create (invalid params 1/2)" do
    post countries_create_url,
      params: {
        name:             "Outro País 7",
        corruption_index: "abc",
        annual_income:    "226,49"
      },
      headers: cabecalho(escrita: true)
    assert_response :bad_request
    assert_nil(Country.find_by(name: "Outro País 7"))
  end

  test "should not post create (invalid params 2/2)" do
    post countries_create_url,
      params: {
        name:             "Outro País 7",
        corruption_index: "27",
        annual_income:    "abc"
      },
      headers: cabecalho(escrita: true)
    assert_response :bad_request
    assert_nil(Country.find_by(name: "Outro País 7"))
  end

  test "should not post create (missing params 1/3)" do
    post countries_create_url,
      params: {
        name:             "Outro País 7",
        corruption_index: "27",
      },
      headers: cabecalho(escrita: true)
    assert_response :bad_request
    assert_nil(Country.find_by(name: "Outro País 7"))
  end

  test "should not post create (missing params 2/3)" do
    post countries_create_url,
      params: {
        name:             "Outro País 7",
        annual_income:    "226,49"
      },
      headers: cabecalho(escrita: true)
    assert_response :bad_request
    assert_nil(Country.find_by(name: "Outro País 7"))
  end

  test "should not post create (missing params 3/3)" do
    post countries_create_url,
      params: {
        corruption_index: "27",
        annual_income:    "226,49"
      },
      headers: cabecalho(escrita: true)
    assert_response :bad_request
    assert_nil(Country.find_by(name: "Outro País 7"))
  end

  test "should not post create (name conflict)" do
    pais = countries(:one)
    post countries_create_url,
      params: {
        name:             pais.name,
        corruption_index: pais.corruption_index,
        annual_income:    pais.annual_income
      },
      headers: cabecalho(escrita: true)
    assert_response :conflict
  end

  test "should put update" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    put countries_update_url(name: pais_1.name),
      params: {
        corruption_index: pais_2.corruption_index,
        annual_income:    pais_2.annual_income
      },
      headers: cabecalho(escrita: true)
    assert_response :ok

    pais_banco = Country.find_by(name: pais_1.name)
    assert_not_nil(pais_banco)
    assert_equal(pais_banco.corruption_index, pais_2.corruption_index)
    assert_equal(pais_banco.annual_income,    pais_2.annual_income)
  end

  test "should put update (new record)" do
    nome = "Novo País 6"
    put countries_update_url(name: nome),
      params: {
        corruption_index: "47",
        annual_income:    "1046,58"
      },
      headers: cabecalho(escrita: true)
    assert_response :created

    pais = Country.find_by(name: nome)
    assert_not_nil(pais)
    assert_equal(pais.corruption_index, 47)
    assert_equal(pais.annual_income, 1046.58)
  end

  test "should not put update (unauthorized)" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    put countries_update_url(name: pais_1.name),
      params: {
        corruption_index: pais_2.corruption_index,
        annual_income:    pais_2.annual_income
      }
    assert_response :unauthorized
  end

  test "should not put update (forbidden)" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    put countries_update_url(name: pais_1.name),
      params: {
        corruption_index: pais_2.corruption_index,
        annual_income:    pais_2.annual_income
      },
      headers: cabecalho(escrita: false)
    assert_response :forbidden
  end

  test "should not put update (missing params 1/2)" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    put countries_update_url(name: pais_1.name),
      params: {
        annual_income:    pais_2.annual_income
      },
      headers: cabecalho(escrita: true)
    assert_response :bad_request
  end

  test "should not put update (missing params 2/2)" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    put countries_update_url(name: pais_1.name),
      params: {
        corruption_index: pais_2.corruption_index,
      },
      headers: cabecalho(escrita: true)
    assert_response :bad_request
  end

  test "should not put update (invalid params 1/2)" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    put countries_update_url(name: pais_1.name),
      params: {
        corruption_index: "abc",
        annual_income:    pais_2.annual_income
      },
      headers: cabecalho(escrita: true)
    assert_response :bad_request
  end

  test "should not put update (invalid params 2/2)" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    put countries_update_url(name: pais_1.name),
      params: {
        corruption_index: pais_2.corruption_index,
        annual_income:    "abc"
      },
      headers: cabecalho(escrita: true)
    assert_response :bad_request
  end

  test "should patch update" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    patch countries_update_url(name: pais_1.name),
      params: {
        corruption_index: pais_2.corruption_index,
        annual_income:    pais_2.annual_income
      },
      headers: cabecalho(escrita: true)
    assert_response :ok

    pais_banco = Country.find_by(name: pais_1.name)
    assert_not_nil(pais_banco)
    assert_equal(pais_banco.corruption_index, pais_2.corruption_index)
    assert_equal(pais_banco.annual_income,    pais_2.annual_income)
  end

  test "should patch update (no changes)" do
    pais = countries(:one)
    patch countries_update_url(name: pais.name),
      headers: cabecalho(escrita: true)
    assert_response :ok

    pais_banco = Country.find_by(name: pais.name)
    assert_not_nil(pais_banco)
    assert_equal(pais_banco.corruption_index, pais.corruption_index)
    assert_equal(pais_banco.annual_income,    pais.annual_income)
  end

  test "should not patch update (unauthorized)" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    patch countries_update_url(name: pais_1.name),
      params: {
        corruption_index: pais_2.corruption_index,
        annual_income:    pais_2.annual_income
      }
    assert_response :unauthorized
  end

  test "should not patch update (forbidden)" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    patch countries_update_url(name: pais_1.name),
      params: {
        corruption_index: pais_2.corruption_index,
        annual_income:    pais_2.annual_income
      },
      headers: cabecalho(escrita: false)
    assert_response :forbidden
  end

  test "should not patch update (invalid params 1/2)" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    patch countries_update_url(name: pais_1.name),
      params: {
        corruption_index: "abc",
        annual_income:    pais_2.annual_income
      },
      headers: cabecalho(escrita: true)
    assert_response :bad_request
  end

  test "should not patch update (invalid params 2/2)" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    patch countries_update_url(name: pais_1.name),
      params: {
        corruption_index: pais_2.corruption_index,
        annual_income:    "abc"
      },
      headers: cabecalho(escrita: true)
    assert_response :bad_request
  end

  test "should not patch update (not found)" do
    nome = "País Não Cadastrado 9"
    patch countries_update_url(name: nome),
      params: {
        corruption_index: "47",
        annual_income:    "1046,58"
      },
      headers: cabecalho(escrita: true)
    assert_response :not_found
    assert_nil(Country.find_by(name: nome))
  end

  test "should delete delete (1/2)" do
    # DELETE http://host:porta/countries/nome_do_pais
    pais = countries(:one)
    delete countries_destroy_url(path_only: true, name: pais.name),
      headers: cabecalho(escrita: true)
    assert_response :ok
    assert_nil(Country.find_by(name: pais.name))
  end

  test "should delete delete (2/2)" do
    # DELETE http://host:porta/countries?name=nome_do_pais
    pais = countries(:two)
    delete countries_destroy_url(name: pais.name),
      headers: cabecalho(escrita: true)
    assert_response :ok
    assert_nil(Country.find_by(name: pais.name))
  end

  test "should not delete destroy (unauthorized)" do
    pais = countries(:one)
    delete countries_destroy_url(path_only: true, name: pais.name)
    assert_response :unauthorized
    assert_not_nil(Country.find_by(name: pais.name))
  end

  test "should not delete destroy (forbidden)" do
    pais = countries(:two)
    delete countries_destroy_url(path_only: true, name: pais.name),
      headers: cabecalho(escrita: false)
    assert_response :forbidden
    assert_not_nil(Country.find_by(name: pais.name))
  end

  test "should not delete destroy (not found)" do
    nome = "País Não Cadastrado"
    assert_nil(Country.find_by(name: nome))
    delete countries_destroy_url(path_only: true, name: nome),
      headers: cabecalho(escrita: true)
    assert_response :not_found
  end

  test "should rename" do
    novo_nome = "Novo Nome de País"
    pais      = countries(:one)
    post countries_rename_url(name: pais.name),
      params: { value: novo_nome },
      headers: cabecalho(escrita: true)
    assert_response :ok
    assert_nil(Country.find_by(name: pais.name))
    assert_not_nil(Country.find_by(name: novo_nome))
  end

  test "should not rename (unauthorized 1/2)" do
    novo_nome = "Novo Nome de País"
    pais      = countries(:two)
    post countries_rename_url(name: pais.name),
      params: { value: novo_nome }
    assert_response :unauthorized
    assert_not_nil(Country.find_by(name: pais.name))
  end

  test "should not rename (unauthorized 2/2)" do
    novo_nome = "Novo Nome de País"
    pais      = countries(:one)
    post countries_rename_url(name: pais.name),
      params: { value: novo_nome },
      headers: cabecalho(escrita: false)
    assert_response :forbidden
    assert_not_nil(Country.find_by(name: pais.name))
  end

  test "should not rename (conflict)" do
    pais_1 = countries(:one)
    pais_2 = countries(:two)
    post countries_rename_url(name: pais_1.name),
      params: { value: pais_2.name },
      headers: cabecalho(escrita: true)
    assert_response :conflict
    assert_not_nil(Country.find_by(name: pais_1.name))
  end

  test "should not rename (not found)" do
    nome_antigo = "País Inexistente (antigo)"
    nome_novo   = "País Inexistente (novo)"
    post countries_rename_url(name: nome_antigo),
      params: { value: nome_novo },
      headers: cabecalho(escrita: true)
    assert_response :not_found
    assert_nil(Country.find_by(name: nome_antigo))
  end
end

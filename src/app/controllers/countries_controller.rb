class CountriesController < ApplicationController
  # renderização HTML
  # include ActionView::Layouts
  # include ActionController::Rendering

  def index
    autorizar_request!
    @countries = Country
      .select(:name, :corruption_index, :annual_income)
      .all
    render json: {"data": @countries}
  end

  def show
    autorizar_request!
    @country = Country
      .select(:name, :corruption_index, :annual_income)
      .where(name: params[:name])
      .take
    render json: {"country": @country}
  end

  def create
    autorizar_request! escrita: true
    params.require([:name, :corruption_index, :annual_income])

    nome   = params[:name]
    indice = processar_indice_corrupcao(params[:corruption_index])
    renda  = processar_renda_anual(params[:annual_income])
    if indice.nil? or renda.nil?
      return request_invalida("invalid parameters")
    end

    @country = Country.new(
      name:             nome,
      corruption_index: indice,
      annual_income:    renda
    )

    if @country.save
      # recurso salvo
      resposta_request("Resource Created", status: :created)
    elsif Country.exists?(@country.id_for_database)
      # recurso não foi salvo por conflito no banco de dados
      erro_request("Conflict", "resource already exists", :conflict)
    elsif @country.invalid?
      # recurso não foi salvo por apresentar parâmetros inválidos
      request_invalida("invalid parameters")
    else
      # algo deu errado de uma forma inesperada
      internal_server_error
    end
  end

  def destroy
    autorizar_request! escrita: true
    params.require(:name)

    if Country.delete_by(name: params[:name]) > 0
      resposta_request("Resource Deleted")
    else
      resposta_request("Not Found", status: :not_found)
    end
  end

  def update
    autorizar_request! escrita: true
    Country.transaction do
      if request.put?
        # método PUT
        params.require([:name, :corruption_index, :annual_income])

        indice = processar_indice_corrupcao(params[:corruption_index])
        renda  = processar_renda_anual(params[:annual_income])
        if indice.nil? or renda.nil?
          return request_invalida("invalid parameters")
        end

        # busca ou cria um novo registro de país
        @country = Country.find_by(name: params[:name]) || Country.new(name: params[:name])

        @country.corruption_index = indice
        @country.annual_income    = renda
      else
        # método PATCH
        params.require(:name)
        @country = Country.find_by!(name: params[:name])

        indice = params[:corruption_index]
        renda  = params[:annual_income]

        if indice.present?
          if indice = processar_indice_corrupcao(indice)
            @country.corruption_index = indice
          else
            return request_invalida("invalid parameters")
          end
        end

        if renda.present?
          if renda = processar_renda_anual(renda)
            @country.annual_income = renda
          else
            return request_invalida("invalid parameters")
          end
        end
      end

      novo_registro = @country.new_record?
      if @country.save
        if novo_registro
          resposta_request("Resource Created", status: :created)
        else
          resposta_request("Resource Updated")
        end
      elsif @country.invalid?
        request_invalida("invalid parameters")
      else
        # algo impediu que o registro fosse atualizado, e isso não inclui
        # ele ter sido alterado entre a busca no começo da função e alteração
        # no final por causa do uso de uma transação
        internal_server_error
      end
    end
  end

  def processar_indice_corrupcao(valor)
    # converte o índice de corrupção em um número se possível,
    # retornando 'nil' caso a conversão falhe
    return valor if valor.is_a?(Integer)

    valor = String.new(valor)
    if valor =~ /^[0-9]+$/
      valor = valor.to_i
      # NOTE: o índice de corrupção vai de 0 a 100
      return valor if (0..100).include?(valor)
    end
  end

  def processar_renda_anual(valor)
    # converte a renda anual média em um número se possível,
    # retornando 'nil' caso a conversão falhe
    return valor if valor.is_a?(Float)

    valor = String.new(valor)
    if valor =~ /^[0-9]+([,.][0-9]+)?$/
      valor = valor.sub(',', '.').to_f
      return valor unless valor < 0
    end
  end
end

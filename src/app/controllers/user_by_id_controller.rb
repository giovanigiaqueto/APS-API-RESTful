class UserByIdController < ApplicationController
  def show
    # busca dados sobre um usuário específico
    autorizar_request! admin: true
    params.require(:id)
    if id = processar_id(params[:id])
      @user = User.find_by!(id: params[:id])
      render json: {"user": @user}
    else
      # NOTE: o ID não é um número válido
      request_invalida("invalid parameters")
    end
  end

  def update
    # atualiza um usuário
    autorizar_request! escrita: true, admin: true
    params.require(:id)
    id = processar_id(params[:id])
    if id.nil?
      # NOTE: o ID não é um número válido
      return request_invalida("invalid parameters")
    end

    @user = User.find_by!(id: params[:id])
    if request.put?
      # método PUT
      params.require([:name, :write, :admin])

      escrita = processar_bool(params[:write])
      admin   = processar_bool(params[:admin])

      if escrita.nil? or admin.nil?
        return request_invalida("invalid parameters")
      end

      @user.name        = params[:name]
      @user.allow_write = escrita
      @user.admin       = admin
    else
      # método PATCH
      nome    = params[:name]
      escrita = params[:write]
      admin   = params[:admin]

      @user.name = nome if nome.present?

      # NOTE: interpreta '0' como 'false' e números maiores
      #       que zero em forma de texto como 'true'
      if escrita.present?
        if escrita = processar_bool(escrita)
          @user.allow_write = escrita
        else
          # NOTE: falha na conversão do parâmetro da request
          return request_invalida("invalid parameters")
        end
      end
      if admin.present?
        if admin = processar_bool(admin)
          @user.admin = admin
        else
          # NOTE: falha na conversão do parâmetro da request
          return request_invalida("invalid parameters")
        end
      end
    end
    if @user.save
      resposta_request("Resource Updated")
    elsif params[:name].present? and User.exists?(params[:name])
      erro_request("Conflict", "resource already exists", :conflict)
    elsif @user.invalid?
      request_invalida("invalid parameters")
    else
      # algo impediu o salvamento do usuário atualizado, que não
      # seja colisão com outro usuário de mesmo nome ou valores
      # inválidos
      internal_server_error
    end
  end

  def destroy
    # remove um usuário
    autorizar_request! escrita: true, admin: true
    params.require(:id)
    id = processar_id(params[:id])
    if id.nil?
      # NOTE: o ID não é um número válido
      request_invalida("invalid parameters")
    elsif User.delete(params[:id]) > 0
      resposta_request("Resource Deleted")
    else
      # NOTE: o recurso não foi encontrado porque ele não foi removido,
      #       e nenhum outro tipo de erro foi gerado
      erro_request("Not Found", "resource not found", :not_found)
    end
  end

  def processar_id(valor)
    # processa o valor fornecido em um ID se ele for convertível
    # implicitamente em uma String (através de String.new(valor))
    # e a String resultante for um número, caso contrário 'nil' é
    # retornado
    valor = String.new(valor) unless valor.is_a?(String)
    if valor.strip =~ /^[0-9]+$/
      return valor.to_i
    end
  rescue TypeError
    # caso a conversão em String falhe, retorne nil
  end

  def processar_bool(valor)
    # processa o valor fornecido em 'true'/'false' se ele for convertível
    # implicitamente em uma String (através de String.new(valor))
    # e a String resultante for um número, caso contrário 'nil' é
    # retornado
    #
    # após a conversão em String, números maiores do que zero são
    # convertidos em 'true' e zero é convertido para 'false'
    valor = String.new(valor) unless valor.is_a?(String)
    if valor.strip =~ /^[0-9]+$/
      return valor.to_i
    end
  rescue TypeError
    # caso a conversão em String falhe, retorne nil
  end
end

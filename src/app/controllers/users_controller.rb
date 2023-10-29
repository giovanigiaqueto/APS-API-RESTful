class UsersController < ApplicationController
  def index
    # lista dados de todos os usuários
    autorizar_request! admin: true
    @users = User.all
    render json: {"data": @users}
  end

  def show
    # busca dados sobre um usuário específico
    autorizar_request! admin: true
    params.require(:name)
    @user = User.find_by!(name: params[:name])
    render json: {"user": @user}
  end

  def create
    # cria um novo usuário
    autorizar_request! escrita: true, admin: true
    params.require(:name)

    escrita = processar_permissao(params[:write])
    admin   = processar_permissao(params[:admin])

    if ((params[:write].present? and escrita.nil?) or
        (params[:admin].present? and admin.nil?))
      return request_invalida("invalid parameters")
    end

    escrita = false if escrita.nil?
    admin   = false if admin.nil?

    User.transaction do
      @user = User.new(
        name:        params[:name],
        allow_write: escrita,
        admin:       admin
      )

      if @user.save
        resposta_request("Resource Created", status: :created)
      elsif User.exists?(name: @user.name)
        erro_request("Conflict", "resource already exists", :conflict)
      elsif @user.invalid?
        request_invalida("invalid parameters")
      else
        internal_server_error
      end
    end
  end

  def update
    # atualiza um usuário
    autorizar_request! escrita: true, admin: true
    params.require(:name)

    User.transaction do
      @user = User.find_by!(name: params[:name])

      if request.put?
        params.require([:write, :admin])

        escrita = processar_permissao(params[:write])
        admin   = processar_permissao(params[:admin])
        if escrita.nil? or admin.nil?
          return erro_request("Bad Request", "invalid parameters", :bad_request)
        end

        @user.allow_write = escrita
        @user.admin       = admin
        @user.save!
      else
        # método patch
        escrita = processar_permissao(params[:write])
        admin   = processar_permissao(params[:admin])
        if ((params[:write].present? and escrita.nil?) or
            (params[:admin].present? and admin.nil?))
          return request_invalida("invalid parameters")
        end

        @user.allow_write = escrita unless escrita.nil?
        @user.admin       = admin   unless admin.nil?
        @user.save!
      end
      resposta_request("Resource Updated")
    end
  end

  def destroy
    # remove um usuário
    autorizar_request! escrita: true, admin: true
    params.require(:name)
    # NOTE: a transação garante que um usuário com o nome da request
    #       não seja criado após a testagem da sua presença
    User.transaction do
      # NOTE: User.find_by! garante que um ActiveRecord::RecordNotFound
      #       seja gerado caso o registro não seja encontrado
      @user = User.find_by!(name: params[:name])
      @user.delete
      resposta_request("Resource Deleted")
    end
  end

  def processar_permissao(permissao)
    self.class.processar_permissao(permissao)
  end

  def self.processar_permissao(permissao)
    case permissao
    in Integer
      permissao > 0
    in TrueClass, FalseClass
      permissao
    in String
      # NOTE: mapeia números maiores que zero para 'true',
      #       mas considera todo o resto como 'false'
      (permissao.to_i > 0) if permissao =~ /^[0-9]+$/
    else
      nil
    end
  end
end

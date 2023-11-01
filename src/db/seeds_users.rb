# Cadastros de usuários pré-definidos que podem ser carregados com o comando bin/rails db:seed:usuarios
# (ou carregados junto com outras tabelas com db:seed, ou criados junto com o banco de dados com db:setup)

module SeedUsers
  def self.create_all(verbose: false)
    # carrega usuários pré-definidos no banco de dados

    # transação para evitar inconsistências ou criação usuários
    # entre o teste de existência e o cadastro dos novos usuários
    User.transaction do
      # usuários a serem cadastrados
      usuario_admin           = User.new(name: 'admin', admin: true)
      usuario_somente_leitura = User.new(name: 'leitura')
      usuario_leitura_escrita = User.new(name: 'leitura-escrita', allow_write: true)

      # ignore os usuários a serem cadastrados se eles já existirem
      if usuario = User.find_by(name: usuario_admin.name)
        if verbose
          puts(
            "usuário '#{usuario_admin.name}' já cadastrado com id #{usuario.id},",
            "  ignorando criação de usuário administrador (admin)",
            ""
          )
        end
        usuario_admin = nil
      end
      if usuario = User.find_by(name: usuario_somente_leitura.name)
        if verbose
          puts(
            "usuário '#{usuario_somente_leitura.name}' já cadastrado com id #{usuario.id},",
            "  ignorando criação de usuário somente leitura",
            ""
          )
        end
        usuario_somente_leitura = nil
      end
      if usuario = User.find_by(name: usuario_leitura_escrita.name)
        if verbose
          puts(
            "usuário '#{usuario_leitura_escrita.name}' já cadastrado com id #{usuario.id},",
            "  ignorando criação de usuário para leitura e escrita",
            ""
          )
        end
        usuario_leitura_escrita = nil
      end
    
      # cadastro dos usuários caso eles não tenham sido ignorados na etapa anterior
      nova_linha = nil
      if usuario = usuario_admin
        usuario.save
        if verbose
          puts("usuário administrador (admin) cadastrado com id #{usuario.id} e nome '#{usuario.name}'")
          nova_linha = true
        end
      end
      if usuario = usuario_somente_leitura
        usuario.save
        if verbose
          puts("usuário somente leitura cadastrado com id #{usuario.id} e nome '#{usuario.name}'")
          nova_linha = true
        end
      end
      if usuario = usuario_leitura_escrita
        usuario.save
        if verbose
          puts("usuário para leitura e escrita cadastrado com id #{usuario.id} e nome '#{usuario.name}'")
          nova_linha = true
        end
      end
      puts("\n") if nova_linha
    end
  end
end


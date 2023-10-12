
class Lazy
  # inicialização tardia de valores
  @cache = {}

  def self.new(label=nil, &block)
    if label
      # retorna uma instância existente
      # ou cria uma nova instância
      @cache[label] ||= super(&block)
    else
      # cria uma nova instância sem label (rotulo)
      super(&block)
    end
  end

  def initialize(&block)
    raise RuntimeError, "missing block" if block.nil?
    @block = block
  end

  def value
    @value ||= @block.call
  end
end

def docker?
  # testa se a tarefa está sendo executada dentro de um container Docker
  not Dir.exist? "../jwt"
end

def sem_docker!
  # garante que a tarefa esteja sendo executada fora de um container Docker
  abort "essa tarefa deve ser executada fora de um container docker" if docker?
end

def nome_token!(nome)
  # valida um nome de token JWT
  abort "nome de token não fornecido" if nome.nil?
  if File.basename(nome, ".txt") != nome or File.basename(nome, ".jwt.txt") != nome
    abort "nome de token invalido"
  end
  nome
end

def flag!(flag, default = false)
  # converte um argumento de uma tarefa para true/false,
  # ou um valor padrão caso não seja possível converter
  #
  # valores verdadeiros:
  #   - strings com números diferentes de zero ("42", "100", "-5" ...)
  #   - strings "true", "on", "yes", "t" ou "y"
  #
  # valores falsos:
  #   - "0" (String)
  #   - strings "false", "off", "no", "f" ou "n"
  #
  if flag.is_a?(String)
    case flag = flag.strip
    when "true", "on", "yes", "t", "y"
      return true
    when "false", "off", "no", "f", "n"
      return false
    when /^[1-9][0-9]*$/
      return flag.to_i != 0
    end
  end
  return flag if flag == true or flag == false
  default
end

def application_controller
  # ApplicationController com inicialização tardia,
  # cria uma instância ApplicationController somente
  # na primeira chamada da função, retornando o mesmo
  # valor em chamadas subsequentes
  controller = Lazy.new :app_controller do
    ApplicationController.new
  end
  controller.value
end

def codificar_jwt(*args, **opts)
  application_controller.codificar_jwt(*args, **opts)
end

def decodificar_jwt(*args, **opts)
  application_controller.decodificar_jwt(*args, **opts)
end

namespace :jwt do
  desc "lista os tokens JWT"
  task :listar, [:header] => :environment do |t, args|
    header = flag!(args.header)
    sem_docker!

    Dir.glob("../jwt/*.jwt.txt").each do |arquivo|
      nome  = File.basename(arquivo, ".jwt.txt")
      token = File.read(arquivo)
      dados = decodificar_jwt(token, hash: true)
      if dados.nil?
        puts("#{nome}: <corrompido>")
      elsif header
        puts("#{nome}: payload=#{dados[:payload]}, header=#{dados[:header]}")
      else
        puts("#{nome}: #{dados[:payload]}")
      end
    end
  end

  desc "mostra um token JWT como JSON"
  task :mostrar, [:token, :header] => :environment do |t, args|
    header = flag!(args.header)
    nome   = nome_token!(args.token)
    sem_docker!

    arquivo = "../jwt/#{nome}.jwt.txt"
    abort "nome de token não encontrado" unless File.exist?(arquivo)

    token = File.read(arquivo)
    dados = decodificar_jwt(token, hash: true)
    if dados.nil?
      puts("#{nome}: <corrompido>")
    elsif header
      puts("#{nome}: payload=#{dados[:payload]}, header=#{dados[:header]}")
    else
      puts("#{nome}: #{dados[:payload]}")
    end
  end

  desc "cria um novo token JWT para um usuário"
  task :novo, [:id, :nome] => :environment do |t, args|
    sem_docker!

    if id = args.id.to_i
      abort "id inválido" if id.nil?
      user = User.find_by(id: id.to_i)
    elsif nome = args.nome
      user = User.find_by(name: nome)
    else
      abort "id ou nome não fornecidos"
    end

    abort "usuário não encontrado" if user.nil?

    # ID + data e horário de última alteração (UTC)
    json = {
      user_id:   user.id,
      timestamp: user.updated_at.to_formatted_s
    }

    payload = JSON.load(json)
    token   = codificar_jwt(payload)
    File.write(arquivo, token)
    puts("token '#{token}' salvo no arquivo #{File.expand_path(arquivo)}")
  end
end

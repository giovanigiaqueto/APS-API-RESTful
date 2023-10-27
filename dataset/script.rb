#!/usr/bin/ruby

# script para carregamento do dataset do arquivo 'dataset/corruption.csv'
# no banco SQLite3 'src/db/development.sqlite3'

# dependências
require 'sqlite3'
require 'csv'

# carregamento do módulo 'pathname' somente quando Pathname é referenciado
autoload :Pathname, 'pathname'

# garante que o script seja executado relativo à pasta do projeto
DIRNAME = File.dirname(__FILE__)
Dir.chdir(File.expand_path('..', DIRNAME))

# REGEX para detectar valores em dólar e converter para Float,
# com separação dos milhões e milhares usando virgula (',')
# e separação das casas decimais usando ponto ('.')
DOLAR_REGEXPR = /^([1-9][0-9]{0,2}(?:,[0-9]{3})*)(?:\.([0-9]+))?\s*\$$/

class DecimalLengthExceededError < Exception
  # causada quando um valor decimal excede
  # a quantidade de casas decimais permitidas
end

OPCOES_VALIDAS = [
  [:h,  :help],
  [:D,  :dry],
].freeze

# aliases
OPCOES_EQUIVALENTES = {
  :ajuda => :help
}

$opcoes = {}
opcoes_invalidas = []

ignorar_opcoes = false
ARGV.filter do |arg|
  if $gnorar_opcoes or arg.strip == '--'
    ignorar_opcoes = true
    true
  elsif opcao = arg.strip.match(/^-([a-zA-Z])|--([a-z]+)$/)
    usado = false
    if opcao_curta = opcao[1]
      sym = opcao_curta.to_sym
      if par = OPCOES_VALIDAS.assoc(sym)
        _, opcao_longa = par
        if opcao_longa.is_a?(Symbol)
          $opcoes[opcao_longa] = true
          usado = true
        end
      else
        opcoes_invalidas <<= arg
        usado = true
      end
    elsif opcao_longa = $opcao[2]
      sym = opcao_longa.to_sym
      if !OPCOES_VALIDAS.rassoc(sym).nil?
        $opcoes[sym] = true
      else
        opcoes_invalidas <<= arg
      end
      usado = true
    end

    not usado
  else
    true
  end
end

if opcao_invalida = opcoes_invalidas.shift
  STDERR.puts("opção invalida: #{opcao_invalida}")
  exit 1
end

def opcao?(flag)
  flag = flag.to_sym if flag.is_a?(String)
  flag = OPCOES_EQUIVALENTES.fetch(flag, flag)
  $opcoes.include?(flag)
end

def mensagem_ajuda
  STDERR.puts(
<<~EOF
uso: ruby [-D|--dry] #{Pathname.new('dataset/script.rb').to_s}

Lê o dataset do arquivo CSV '#{Pathname.new('dataset/corruption.csv')}',
faz as conversões adequadas, e carrega os dados no baco SQLite3 do arquivo
'#{Pathname.new('src/db/development.sqlite3').to_s}'.

Esse script não cria o banco de dados, isso deve ser feito através do rails com
o subcomando db:migration:load, que deve ser executado com 'bin/bundle exec bin/rails'
dentro da pasta 'src'.

Opções:
    -D, --dry  executa o script sem tocar no banco de dados, o que pode ser usado
               para testar se os arquivos do dataset e o banco de dados existem,
               e os dados do dataset podem ser interpretados corretamente
EOF
  )
end

def ajuda(cod_saida = 1)
  mensagem_ajuda
  exit cod_saida.to_int
end

if opcao?(:ajuda)
  ajuda
end

def converter_dolar_hash?(valor)
  # faz a conversão de dólares separados por virgulas e pontos
  # (e.g. 12,345,678.90) para um hash '{int: 123, frac: 456, digitos: 3}'
  # contendo a parte inteira e fracionária (se existir) dois inteiros,
  # e a quantidade de dígitos caso o valor for decimal
  if match = valor.match(DOLAR_REGEXPR)
    inteiro = match[1]
      .split(',')
      .reverse
      .each_with_index
      .map{|v,i| v.to_i * (1000 ** i)}
      .sum
    if fracao = match[2]
      {int: inteiro, frac: fracao.to_i, digitos: fracao.size}
    else
      {int: inteiro}
    end
  end
end

def converter_dolar(valor, digitos = nil, round: true, fallback: nil)
  if hash = converter_dolar_hash?(valor)
    if hash[:frac].nil? or hash[:digitos].nil?
      return hash[:int]
    end

    decimal = hash[:frac] * (0.1 ** hash[:digitos])

    if digitos and digitos.to_int < hash.fetch(:digitos, 0)
      if round
        decimal = decimal.round(digitos)
      else
        raise DecimalLengthExceededError, "exceeded max decimal length of #{digitos}"
      end
    end

    hash[:int] + decimal
  else
    fallback
  end
end

def converter_header(header)
  # converte o nome de algumas colunas do CSV
  case header
  when "Ø Annual income"
    "Annual income"
  else
    header
  end
end

def csv?(path, digitos: 2, round: false)
  # lê e processa o arquivo CSV
  CSV.read(
    path,
    headers: true,
    header_converters: [
      ->(valor) { converter_header(valor) }
    ],
    converters: [
      :integer,
      ->(valor) {
        converter_dolar(valor, digitos = digitos, round: round, fallback: valor)
      }
    ],
  )
end

def array_csv?(path, **opt)
  # lê o CSV em um array de linhas
  linhas = []
  csv = csv?(path, **opt)
  csv.each_with_index do |linha,idx|
    pais  = linha['Country']
    rank  = linha['Corruption index']
    renda = linha['Annual income']
    if pais.nil? or rank.nil? or renda.nil?
      raise RuntimeError, "dados invalidos na entrada #{idx}"
    end
    linhas.push([pais, rank, renda])
  end
  linhas
end

digitos_csv    = 2
arredondar_csv = false
begin
  dados_csv = array_csv?(
    'dataset/corruption.csv',
    digitos: digitos_csv,
    round:   arredondar_csv
  )
rescue DecimalLengthExceededError
  STDOUT.write([
    "há valores decimais que excedem os limites",
    "de precisão do banco de dados, arredondar? (s/n)",
    "~> "
  ].join("\n"))
  begin
    resposta = STDIN.readline.strip
  rescue Interrupt
    STDERR.puts("abortado\n")
    exit 1
  end
  if resposta.match?(/^[Ss](im)?|SIM$/)
    arredondar_csv = true
    retry
  else
    STDERR.puts("abortado")
    exit 1
  end
end

# detecta se o banco de dados ainda não foi criado
unless File.exist?('src/db/development.sqlite3')
  norm_path = ->(path) { Pathname.new(path).to_s } 
  STDERR.puts([
    "arquivo não encontrado: #{norm_path('src/db/development.sqlite3')}",
    "",
    "execute 'ruby #{norm_path('bin/bundle')} exec #{norm_path('bin/rails')} db:schema:load'",
    "dentro da pasta 'src' para gerar o banco de dados através do rails",
    "",
    "caso o comando falhe por causa de dependências faltantes, execute",
    "'#{norm_path('bin/bundle')} install --deployment' dentro da pasta 'src'",
    "para instalar localmente as gems necessárias para executar o rails",
    "e tente novamente"
  ].join("\n"))
  exit 1
end

begin
  db = SQLite3::Database.open 'src/db/development.sqlite3'
  # NOTE: uma transaction foi usada por conta das limitações do SQLite
  db.transaction {|db|
    db.prepare('DELETE FROM countries WHERE name == ?') {|stmt|
      dados_csv.each{|linha|
        if not opcao?(:dry)
          stmt.execute(linha[0])
          puts "country '#{linha[0]}' removed"
        else
          puts "(dry run) country '#{linha[0]}' removed"
        end
      }
    }
    db.prepare(%Q(
INSERT INTO
  countries(name, corruption_index, annual_income, created_at, updated_at)
VALUES
  (?, ?, ?, date('now'), date('now'))
)) {|stmt|
      dados_csv.each{|linha|
        if not opcao?(:dry)
          stmt.execute(*linha)
          puts "country '#{linha}' inserted"
        else
          puts "(dry run) country '#{linha}' inserted"
        end
      }
    }
  }
rescue
  raise
ensure
  db.close if db
end


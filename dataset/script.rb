#!/usr/bin/ruby

require 'sqlite3'
require 'csv'

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
        stmt.execute(linha[0])
        puts "country '#{linha[0]}' removed"
      }
    }
    db.prepare(%Q(
INSERT INTO
  countries(name, corruption_index, annual_income, created_at, updated_at)
VALUES
  (?, ?, ?, date('now'), date('now'))
)) {|stmt|
      dados_csv.each{|linha|
        stmt.execute(*linha)
        puts "country '#{linha}' inserted"
      }
    }
  }
rescue
  raise
ensure
  db.close if db
end



autoload :CSV, 'csv'

module Dataset
  # modulo contendo funções e classes relacionadas ao carregamento do dataset

  def self.decimal(texto, sep_milhar: nil, sep_decimal: nil)
    # converte valores decimais em um formato específico (como '123,456.789',
    # '123456.789', '123.467,789' ou '123456,789') para Float se possível,
    # retornando 'nil' caso a conversão falhe
    #
    # gera ArgumentError caso a entrada não possa ser convertida
    # implicitamente para String

    texto = texto.to_str.strip

    sep_milhar = sep_milhar.to_str unless sep_milhar.nil?
    if sep_decimal.nil?
      sep_decimal = '.'
    else
      sep_decimal = sep_decimal.to_str
    end

    if sep_milhar == sep_decimal
      raise ArgumentError, "sep_milhar and sep_decimal must be different"
    end

    if indice = texto.index(sep_decimal)
      parte_inteira     = texto[...indice]
      parte_fracionaria = texto[(indice + 1)...]

      parte_inteira.delete(sep_milhar) unless sep_milhar.nil?

      # testa se o número está mal formado:
      #   
      #   1. separador de milhar após separador de casas decimais)
      #   2. separador de casas decimais ocorre múltiplas vezes
      #
      return nil if sep_milhar and parte_fracionaria.include?(sep_milhar)
      return nil if parte_fracionaria.include?(sep_decimal)

      # testa se as partes são números válidos
      return nil if parte_inteira !~ /^[0-9]+$/ or parte_fracionaria !~ /^[0-9]+$/

      [parte_inteira, '.', parte_fracionaria].join.to_f
    else
      # retorna o valor convertido se o texto for um número inteiro válido
      texto = texto.delete(sep_milhar) unless sep_milhar.nil?
      texto.to_f if texto =~ /^[0-9]+$/
    end
  end

  def self.converter_header(valor)
    case valor.strip
    when /^[Cc]ountry$/, /^[Pp]a[ií]s$/
      "nome"
    when /^[Cc]orruption [Ii]ndex$/, /^[IiÍí]ndice de [Cc]orrup(ção|cao)$/
      "indice de corrupcao"
    when /^(Ø )?[Aa]nnual [Ii]ncome$/, /^[Rr]enda [Aa]nual$/
      "renda anual media"
    else
      valor
    end
  end

  def self.ler_csv(path, headers: true)
    csv = CSV.read(
      path,
      headers: headers,
      header_converters: [
        ->(valor) { self.converter_header(valor) }
      ],
      converters: [
        :integer,
        ->(valor) {
          self.decimal(
            valor.delete_suffix('$').rstrip,
            sep_milhar: ',',
            sep_decimal: '.'
          ) or valor
        }
      ]
    )

    if headers
      # validação dos cabeçalhos do CSV
      headers = Set.new(csv.headers)
      raise CSVHeaderError, "too few headers" if headers.size < 3
      raise CSVHeaderError, "too many headers" if headers.size > 3

      headers_validos = Set.new(["nome", "indice de corrupcao", "renda anual media"])
      faltantes    = (headers_validos - headers).to_a
      desconhecido = (headers - headers_validos).to_a
      if header = faltantes.pop
        raise CSVHeaderError, "missing '#{header}' header"
      end
      if header = desconhecido.pop
        raise CSVHeaderError, "unknown '#{desconhecido}' header"
      end
    end

    csv
  end

  class CSVHeaderError < Exception
    # classe para erros relacionados aos headers do CSV carregado
  end

  class Pais
    # representação de um País no dataset

    def initialize(nome, indice_corrupcao, salario_anual)
      self.nome    = nome
      self.indice  = indice_corrupcao
      self.salario = salario_anual
    end

    attr_reader :nome, :indice, :salario

    def nome=(valor)
      nome = valor.to_str
      raise RuntimeError, "attribute can't be set to empty string" if nome.empty?
      @nome = nome
    end

    def indice=(valor)
      indice = valor.to_int
      raise RuntimeError, "attribute can't be set to negative value" if indice < 0
      @indice = indice
    end

    def salario=(valor)
      if valor.is_a?(Float)
        salario = valor.dup
      elsif valor.is_a?(Integer)
        salario = valor.to_f
      else
        raise TypeError, "invalid value for 'salario=' (not a Integer or Float)"
      end

      raise RuntimeError, "attribute can't be set to negative value" if salario < 0
      @salario = salario
    end

    def to_a
      [@nome.dup, @indice.dup, @salario.dup]
    end

    def to_h
      {nome: @nome.dup, indice: @indice.dup, salario: @salario.dup}
    end
  end

  class Dados
    # representação do dataset convertido e pronto para ser carregado no banco de dados

    include Enumerable

    def initialize(&block)
      @tabela = []
      if block_given?
        for valor in Enumerator.new(&block)
          self << valor
        end
      end
    end

    def <<(valor)
      # insere um valor no dataset
      if valor.is_a?(Pais)
        @tabela <<= valor
      else
        raise TypeError, "invalid value to push (not a Dataset::Pais value)"
      end
    end

    def [](indice)
      # indexação pelo índice no dataset
      @tabela[indice]
    end

    def include?(pais)
      # verifica se um país está presente no dataset
      @tabela.include?(pais)
    end

    def size
      # quantidade de linhas no dataset
      @tabela.size
    end

    alias :push :<<
  end
end


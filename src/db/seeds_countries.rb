# Carregamento dos países do dataset no banco de dados através do comando bin/rails db:seed:paises
# (ou carregados junto com outras tabelas com db:seed, ou criados junto com o banco de dados com db:setup)
#
# NOTE: o módulo SeedCountries desse arquivo é usado internamente pela task Rake "db:seed:paises"

require_relative '../lib/aux/dataset.rb'

module SeedCountries
  def self.load_data
    dados = Dataset::Dados.new
    Dataset.ler_csv('../dataset/corruption.csv').each do |linha|
      dados <<= Dataset::Pais.new(
        linha['nome'],
        linha['indice de corrupcao'],
        linha['renda anual media']
      )
    end
    dados
  end

  def self.create_all(verbose: nil)
    case verbose
    when true, false
      verbose = (verbose ? 1:0)
    when nil
      verbose = 1
    else
      if verbose.respond_to?(:to_int)
        verbose = verbose.to_int
      else
        verbose = verbose.to_i
      end
      verbose = 0 if verbose < 0
    end

    dados = self.load_data
    puts("#{dados.size} países lidos do dataset, iniciando carregamento") if verbose > 0

    carregados = 0
    Country.transaction do
      dados.each do |pais|
        registro = Country.new(
          name:             pais.nome,
          corruption_index: pais.indice,
          annual_income:    pais.salario
        )

        if Country.exists?(name: registro.name)
          puts("país '#{registro.name}' já cadastrado, ignorando...") if verbose > 1
        else
          registro.save!
          puts([
            "país '#{registro.name}' carregado,",
            "índice=#{registro.corruption_index},",
            "renda=#{registro.annual_income}"
          ].join(' ')) if verbose > 1
        end
      end
    end

    puts("#{carregados} paises carregados no banco") if verbose > 0
    nil
  end
end

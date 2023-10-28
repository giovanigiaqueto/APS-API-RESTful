
require_relative '../../db/seeds_users.rb'
require_relative '../../db/seeds_countries.rb'

namespace :db do
  namespace :seed do
    desc "Carrega o banco de dados com usuários pré-definidos"
    task :usuarios => [:environment] do
      # NOTE: SeedUsers está definido no arquivo db/seed_users.rb
      SeedUsers.create_all(verbose: true)
    end

    desc "Carrega o banco de dados com os países do dataset"
    task :paises => [:environment] do
      # NOTE: SeedCountries está definido no arquivo db/seed_countries.rb
      verbose = ENV['VERBOSE']
      verbose = verbose.to_i unless verbose.nil?
      SeedCountries.create_all(verbose: verbose)
    end
  end
end

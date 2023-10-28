
require_relative '../../db/seeds_users.rb'

namespace :db do
  namespace :seed do
    desc "Carrega o banco de dados com usuários pré-definidos"
    task :usuarios => [:environment] do
      # NOTE: SeedUsers está definido no arquivo db/seed_users.rb
      SeedUsers.create_all(verbose: true)
    end
  end
end

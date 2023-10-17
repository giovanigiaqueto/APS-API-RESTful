# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

module SeedsHelper
  BANNER_SIZE = 80

  def self.banner(texto, borda = '=', largura = nil)
    largura = SeedsHelper::BANNER_SIZE
    [borda * largura, texto.center(largura), borda * largura].join("\n")
  end

  def self.banner_tarefa(tarefa, largura = nil)
    self.banner("executando tarefa Rake '#{tarefa}'", borda = '-', largura = largura)
  end
end

if Rake::Task.task_defined?('db:seed:usuarios')
  puts(
    "\n",
    SeedsHelper::banner("carregando usuários pré-definidos no banco de dados"),
    "\n",
    SeedsHelper::banner_tarefa('db:seed:usuarios'),
    "\n"
  )
  Rake.application['db:seed:usuarios'].invoke
end

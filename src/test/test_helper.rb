ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def url_for(**opt)
    method(:url_for).super_method.call(host: host, port: port, **opt)
  end

  def users_index_url(**opt)
    url_for(controller: :users, action: 'index', **opt)
  end

  def users_show_url(**opt)
    url_for(controller: :users, action: 'show', only_path: true, **opt)
  end

  def users_create_url(**opt)
    url_for(controller: :users, action: 'create', **opt)
  end

  def users_update_url(**opt)
    url_for(controller: :users, action: 'update', **opt)
  end

  def users_destroy_url(**opt)
    url_for(controller: :users, action: 'destroy', only_path: true, **opt)
  end

  def countries_index_url(**opt)
    url_for(controller: :countries, action: 'index', **opt)
  end

  def countries_show_url(**opt)
    url_for(controller: :countries, action: 'show', path_only: true, **opt)
  end

  def countries_create_url(**opt)
    url_for(controller: :countries, action: 'create', **opt)
  end

  def countries_update_url(**opt)
    url_for(controller: :countries, action: 'update', path_only: true, **opt)
  end

  def countries_destroy_url(**opt)
    url_for(controller: :countries, action: 'destroy', path_only: true, **opt)
  end

  def host
    "localhost"
  end

  def port
    3000
  end

  def application
    @app ||= ApplicationController.new
  end

  def jwt_simples
    @usuario_simples ||= users(:simples)
    @token_simples   ||= application.codificar_jwt({
      user_id:   @usuario_simples.id,
      timestamp: @usuario_simples.updated_at
    })
  end

  def jwt_escrita
    @usuario_escrita ||= users(:escrita)
    @token_escrita   ||= application.codificar_jwt({
      user_id:   @usuario_escrita.id,
      timestamp: @usuario_escrita.updated_at
    })
  end

  def jwt_admin
    @usuario_admin ||= users(:admin)
    @token_admin   ||= application.codificar_jwt({
      user_id:   @usuario_admin.id,
      timestamp: @usuario_admin.updated_at
    })
  end
end

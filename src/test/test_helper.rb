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

  def users_rename_url(**opt)
    url_for(controller: :users, action: 'rename', only_path: true, **opt)
  end

  def user_by_id_show_url(**opt)
    url_for(controller: :user_by_id, action: 'show', only_path: true, **opt)
  end

  def user_by_id_update_url(**opt)
    url_for(controller: :user_by_id, action: 'update', only_path: true, **opt)
  end

  def user_by_id_destroy_url(**opt)
    url_for(controller: :user_by_id, action: 'destroy', only_path: true, **opt)
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

  def countries_rename_url(**opt)
    url_for(controller: :countries, action: 'rename', path_only: true, **opt)
  end

  def gerar_id_disponivel(cls, sym = :id)
    if not cls.is_a?(Class) and cls < ActiveModel::Base
      raise ArgumentError, "expected 'cls' to be a subclass of ActiveMode::Base"
    elsif not sym.is_a?(Symbol)
      raise ArgumentError, "expected 'sym' to be a Symbol for use as ID field name"
    end

    id = (1000 * Random.rand()).to_i
    for _ in 0..1000 do
      if cls.exists?(sym => id)
        id += 1
      else
        break
      end
    end
    flunk("unable to generate unused ID") if cls.exists?(sym => id)
    id
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

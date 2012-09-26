require 'hyperion/sql'

module Hyperion
  module Sql

    # = Middleware
    #
    # This rack middleware will do the following
    #
    #   1. Wrap the request with a db connection using the :connection_url option
    #   2. Wrap the request with a datastore using the :ds and :ds_opts options
    #   3. Wrap the request with a transaction
    #
    # Examples
    #
    # 1. sqlite3
    #
    # use Hyperion::Sql::Middleware connection_url: 'sqlite3::memory:', db: :sqlite
    #
    # with Rails...
    # config.middleware.use Hyperion::Sql::Middleware connection_url: 'sqlite3::memory:', ds: :sqlite
    #
    # 2. postgres
    #
    # use Hyperion::Sql::Middleware connection_url: 'postgres://localhost/hyperion_ruby', ds: :postgres

    class Middleware

      def initialize(app, opts={})
        @app = app
        @connection_url = opts[:connection_url]
        @ds = opts[:ds]
        @ds_opts = opts[:ds_opts] || {}
      end

      def call(env)
        Hyperion.with_datastore(@ds, @ds_opts.merge(:connection_url => @connection_url)) do
          Sql.with_connection(@connection_url) do
            Sql.transaction do
              @app.call(env)
            end
          end
        end

      end
    end
  end
end


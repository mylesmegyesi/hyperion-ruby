require 'do_postgres'
require 'hyperion/sql/datastore'
require 'hyperion/postgres/query_builder_strategy'
require 'hyperion/postgres/query_executor_strategy'
require 'hyperion/postgres/db_strategy'

module Hyperion
  module Postgres

    def self.new(opts={})
      Sql::Datastore.new(opts[:connection_url], DbStrategy.new, QueryExecutorStrategy.new, QueryBuilderStrategy.new)
    end

  end
end

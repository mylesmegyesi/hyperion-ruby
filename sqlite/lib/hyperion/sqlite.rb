require 'do_sqlite3'
require 'hyperion/sql/datastore'
require 'hyperion/sqlite/query_builder_strategy'
require 'hyperion/sqlite/query_executor_strategy'
require 'hyperion/sqlite/db_strategy'

module Hyperion
  module Sqlite

    def self.new(opts={})
      Sql::Datastore.new(opts[:connection_url], DbStrategy.new, QueryExecutorStrategy.new, QueryBuilderStrategy.new)
    end

  end
end

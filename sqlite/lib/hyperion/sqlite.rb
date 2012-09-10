require 'hyperion/sql/datastore'
require 'hyperion/sqlite/query_builder_strategy'
require 'hyperion/sqlite/query_executor_strategy'
require 'hyperion/sqlite/db_strategy'

module Hyperion
  module Sqlite

    def self.create_datastore
      Sql::Datastore.new(DbStrategy.new, QueryExecutorStrategy.new, QueryBuilderStrategy.new)
    end

  end
end

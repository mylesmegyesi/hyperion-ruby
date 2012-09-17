require 'do_mysql'
require 'hyperion/sql/datastore'
require 'hyperion/mysql/query_builder_strategy'
require 'hyperion/mysql/query_executor_strategy'
require 'hyperion/mysql/db_strategy'

module Hyperion
  module Mysql

    def self.new(opts={})
      Sql::Datastore.new(DbStrategy.new, QueryExecutorStrategy.new, QueryBuilderStrategy.new)
    end

  end
end

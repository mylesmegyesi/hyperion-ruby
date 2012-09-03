require 'hyperion/sql/datastore'
require 'hyperion/sql/query_builder'
require 'hyperion/postgres/query_builder_strategy'

module Hyperion
  module Postgres

    def self.create_datastore
      Sql::Datastore.new(Sql::QueryBuilder.new(QueryBuilderStrategy.new))
    end

  end
end

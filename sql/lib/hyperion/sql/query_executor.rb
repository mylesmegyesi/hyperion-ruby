require 'hyperion/sql'

module Hyperion
  module Sql

    class QueryExecutor

      attr_reader :strategy

      def initialize(strategy)
        @strategy = strategy
      end

      def execute_mutation(sql_query)
        command = connection.create_command(sql_query.query_str)
        command.execute_non_query(*sql_query.bind_values)
      end

      def execute_query(sql_query)
        command = connection.create_command(sql_query.query_str)
        command.execute_reader(*sql_query.bind_values).to_a
      end

      def execute_write(sql_query)
        strategy.execute_write(sql_query)
      end

      def connection
        Sql.connection
      end

    end

  end
end

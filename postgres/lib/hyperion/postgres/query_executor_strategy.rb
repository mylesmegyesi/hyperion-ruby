require 'hyperion/sql/connection'

module Hyperion
  module Postgres

    class QueryExecutorStrategy

      def execute_write(sql_query)
        command = Sql::Connection.connection.create_command(sql_query.query_str)
        command.execute_reader(*sql_query.bind_values).to_a
      end

    end

  end
end

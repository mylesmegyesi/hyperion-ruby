require 'hyperion/sql/connection'

module Hyperion
  module Sqlite
    class QueryExecutorStrategy

      def execute_write(sql_query)
        command = Sql::Connection.connection.create_command(sql_query.query_str)
        command.execute_non_query(*sql_query.bind_values)
      end

    end
  end
end


require 'hyperion/sql'

module Hyperion
  module Mysql
    class QueryExecutorStrategy

      def execute_write(sql_query)
        command = Sql.connection.create_command(sql_query.query_str)
        command.execute_non_query(*sql_query.bind_values)
      end

    end
  end
end


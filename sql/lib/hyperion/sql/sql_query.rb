
module Hyperion
  module Sql

    class SqlQuery
      attr_reader :query_str, :bind_values

      def initialize(query_str, bind_values=[])
        @query_str = query_str
        @bind_values = bind_values || []
      end

      def append(str, values=[])
        @query_str << " #{str}"
        @bind_values += values if values
      end
    end
  end
end

module Hyperion
  module Mysql

    class QueryBuilderStrategy
      def quote_tick
        '`'
      end

      def apply_limit_and_offset(sql_query, limit, offset)
        limit = limit || 9223372036854775807
        offset = offset || 0
        sql_query.append("LIMIT ?, ?", [offset, limit])
      end

      def normalize_insert(sql_query_str)
        sql_query_str
      end

      def normalize_update(sql_query_str)
        sql_query_str
      end
    end

  end
end

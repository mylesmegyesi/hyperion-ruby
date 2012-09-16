require 'hyperion/key'
require 'hyperion/sql/sql_query'

module Hyperion
  module Sql

    class QueryBuilder

      def initialize(qb_strategy)
        @qb_strategy = qb_strategy
      end

      def build_insert(record)
        record = record.dup
        table = format_table(record.delete(:kind))
        unless record.empty?
          columns = format_array(record.keys.map {|c| format_column(c) })
          values = format_array(record.values.map {|v| '?'})
          query = "INSERT INTO #{table} #{columns} VALUES #{values}"
        else
          query = qb_strategy.empty_insert_query(table)
        end
        SqlQuery.new(qb_strategy.normalize_insert(query), record.values)
      end

      def build_update(record)
        record = record.dup
        table, id = Key.decompose_key(record.delete(:key))
        table = format_table(record.delete(:kind))
        column_values = record.keys.map {|field| "#{format_column(field)} = ?"}
        query = qb_strategy.normalize_update("UPDATE #{table} SET #{column_values.join(', ')} WHERE #{quote('id')} = #{id}")
        SqlQuery.new(query, record.values)
      end

      def build_select(query)
        sql_query = SqlQuery.new("SELECT * FROM \"#{query.kind}\"")
        apply_filters(sql_query, query.filters)
        apply_sorts(sql_query, query.sorts)
        qb_strategy.apply_limit_and_offset(sql_query, query.limit, query.offset)
        sql_query
      end

      def build_delete(query)
        sql_query = SqlQuery.new("DELETE FROM \"#{query.kind}\"")
        apply_filters(sql_query, query.filters)
        sql_query
      end

      def build_count(query)
        sql_query = SqlQuery.new("SELECT COUNT(*) FROM \"#{query.kind}\"")
        apply_filters(sql_query, query.filters)
        sql_query
      end

      private

      attr_reader :qb_strategy

      def quote(str)
        tick = qb_strategy.quote_tick
        tick + str.to_s.gsub(tick, tick + tick) + tick
      end

      def format_column(column)
        quote(column)
      end

      def format_table(table)
        quote(table)
      end

      def format_array(arr)
        "(#{arr.join(', ')})"
      end

      def apply_filters(sql_query, filters)
        if filters.empty?
          sql_query
        else
          filter_sql = []
          filter_values = []
          filters.each do |filter|
            filter_sql << "#{format_column(filter.field)} #{format_operator(filter.operator)} ?"
            filter_values << filter.value
          end
          sql_query.append("WHERE #{filter_sql.join(' AND ')}", filter_values)
        end
      end

      def format_operator(operator)
        case operator
        when 'contains?'
          "IN"
        when '!='
          "<>"
        else
          operator
        end
      end

      def apply_sorts(sql_query, sorts)
        if sorts.empty?
          sql_query
        else
          sort_sql = []
          sort_values = []
          sort_sql = sorts.map do |sort|
            "#{format_column(sort.field)} #{format_order(sort.order)}"
          end
          sql_query.append("ORDER BY #{sort_sql.join(', ')}")
        end
      end

      def format_order(order)
        case order
        when :asc
          "ASC"
        when :desc
          "DESC"
        end
      end
    end

  end
end

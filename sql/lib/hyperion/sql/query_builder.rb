require 'hyperion/key'
require 'hyperion/sql/sql_query'
require 'hyperion/util'

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
        Util.snake_case(quote(column))
      end

      def format_table(table)
        Util.snake_case(quote(table))
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
            apply_filter(filter, filter_sql, filter_values)
          end
          sql_query.append("WHERE #{filter_sql.join(' AND ')}", filter_values)
        end
      end

      def apply_filter(filter, filter_sql, filter_values)
        column = format_column(filter.field)
        if filter.operator == '!='
          if filter.value.nil?
            filter_sql << "#{column} IS NOT NULL"
          else
            filter_sql << "(#{column} != ? OR #{column} IS NULL)"
            filter_values << filter.value
          end
        elsif filter.operator == 'contains?'
          if filter.value.include?(nil)
            filter_sql << "(#{column} IN ? OR #{column} IS NULL)"
          else
            filter_sql << "#{column} IN ?"
          end
          filter_values << filter.value
        elsif filter.operator == 'like?'
          filter_sql << "#{column} LIKE ?"
          filter_values << "%#{filter.value}%"
        elsif filter.operator == '=' && filter.value.nil?
          filter_sql << "#{column} IS NULL"
        else
          filter_sql << "#{column} #{filter.operator} ?"
          filter_values << filter.value
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

require 'hyperion/core'

module Hyperion

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

  class Postgres

    class << self
      attr_accessor :connection
    end

    def save(records)
      records.map do |record|
        save_record(record)
      end
    end

    def find_by_key(key)
      table, id = decompose_key(key)
      query = Query.new(table, [Filter.new(:id, '=', id)], nil, nil, nil)
      find(query).first
    end

    def find(query)
      sql_query = SqlQuery.new("SELECT * FROM \"#{query.kind}\"")
      apply_filters(sql_query, query.filters)
      apply_sorts(sql_query, query.sorts)
      apply_limit_and_offset(sql_query, query.limit, query.offset)
      command = connection.create_command(sql_query.query_str)
      results = command.execute_reader(*sql_query.bind_values).to_a
      results.map {|record| record_from_db(record, query.kind) }
    end

    def delete_by_key(key)
      table, id = decompose_key(key)
      query = Query.new(table, [Filter.new(:id, '=', id)], nil, nil, nil)
      delete(query)
    end

    def delete(query)
      sql_query = SqlQuery.new("DELETE FROM \"#{query.kind}\"")
      apply_filters(sql_query, query.filters)
      command = connection.create_command(sql_query.query_str)
      command.execute_non_query(*sql_query.bind_values)
      nil
    end

    def count(query)
      sql_query = SqlQuery.new("SELECT COUNT(*) FROM \"#{query.kind}\"")
      apply_filters(sql_query, query.filters)
      command = connection.create_command(sql_query.query_str)
      results = command.execute_reader(*sql_query.bind_values).to_a
      results[0]['count']
    end

    private

    def record_from_db(record, table)
      record[:key] = compose_key(table, record.delete('id'))
      record[:kind] = table
      record
    end

    def apply_limit_and_offset(sql_query, limit, offset)
      apply_limit(sql_query, limit)
      apply_offset(sql_query, offset)
    end

    def apply_limit(sql_query, limit)
      if limit
        sql_query.append("LIMIT ?", [limit])
      end
    end

    def apply_offset(sql_query, offset)
      if offset
        sql_query.append("OFFSET ?", [offset])
      end
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

    def connection
      self.class.connection
    end

    def save_record(record)
      query = Core.new?(record) ? build_insert_query(record) : build_update_query(record)
      command = connection.create_command(query.query_str)
      result = command.execute_reader(*query.bind_values).to_a
      record_from_db(result[0], record[:kind])
    end

    def build_insert_query(record)
      record = record.dup
      kind = record.delete(:kind)
      table = "\"#{kind}\""
      columns = format_array(record.keys.map {|c| format_column(c) })
      values = format_array(record.values.map {|v| '?'})
      query = "INSERT INTO #{table} #{columns} VALUES #{values} RETURNING *"
      SqlQuery.new(query, record.values)
    end

    def build_update_query(record)
      record = record.dup
      table, id = decompose_key(record.delete(:key))
      table = format_table(record.delete(:kind))
      column_values = record.keys.map {|field| "#{format_column(field)} = ?"}
      query = "UPDATE #{table} SET #{column_values.join(', ')} WHERE \"id\" = #{id} RETURNING *"
      SqlQuery.new(query, record.values)
    end

    def compose_key(table, id)
      "#{table}-#{id}"
    end

    def decompose_key(key)
      parts = key.rpartition('-')
      [parts.first, parts.last]
    end

    def format_column(column)
      "\"#{column}\""
    end

    def format_table(table)
      "\"#{table}\""
    end

    def format_array(arr)
      "(#{arr.join(', ')})"
    end
  end
end

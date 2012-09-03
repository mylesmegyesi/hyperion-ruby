require 'hyperion/core'
require 'hyperion/sql/connection'
require 'hyperion/sql/key'

module Hyperion
  module Sql

    class Datastore

      def initialize(query_builder)
        @query_builder = query_builder
      end

      def save(records)
        records.map do |record|
          sql_query = Core.new?(record) ? query_builder.build_insert(record) : query_builder.build_update(record)
          result = execute_write(sql_query)
          record_from_db(result[0], record[:kind])
        end
      end

      def find_by_key(key)
        find(query_from_key(key)).first
      end

      def find(query)
        sql_query = query_builder.build_select(query)
        results = execute_query(sql_query)
        results.map { |record| record_from_db(record, query.kind) }
      end

      def delete_by_key(key)
        delete(query_from_key(key))
      end

      def delete(query)
        sql_query = query_builder.build_delete(query)
        execute_mutation(sql_query)
        nil
      end

      def count(query)
        sql_query = query_builder.build_count(query)
        results = execute_query(sql_query)
        results[0]['count']
      end

      private

      attr_reader :query_builder

      def connection
        Connection.connection
      end

      def record_from_db(record, table)
        record[:key] = Key.compose_key(table, record.delete('id'))
        record[:kind] = table
        record
      end

      def query_from_key(key)
        table, id = Key.decompose_key(key)
        Query.new(table, [Filter.new(:id, '=', id)], nil, nil, nil)
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
        command = connection.create_command(sql_query.query_str)
        command.execute_reader(*sql_query.bind_values).to_a
      end

    end

  end
end

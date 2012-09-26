require 'hyperion'
require 'hyperion/key'
require 'hyperion/sql/query_builder'
require 'hyperion/sql/query_executor'

module Hyperion
  module Sql

    class Datastore

      def initialize(connection_url, db_strategy, query_executor_strategy, query_builder_strategy)
        @connection_url = connection_url
        @db_strategy = db_strategy
        @query_executor = QueryExecutor.new(query_executor_strategy)
        @query_builder = QueryBuilder.new(query_builder_strategy)
      end

      def save(records)
        with_connection do
          records.map do |record|
            if Hyperion.new?(record)
              execute_save_query(query_builder.build_insert(record), record)
            elsif non_empty_record?(record)
              execute_save_query(query_builder.build_update(record), record)
            else
              record
            end
          end
        end
      end

      def find_by_key(key)
        with_connection do
          find(query_from_key(key)).first
        end
      end

      def find(query)
        with_connection do
          sql_query = query_builder.build_select(query)
          results = query_executor.execute_query(sql_query)
          results.map { |record| record_from_db(record, query.kind) }
        end
      end

      def delete_by_key(key)
        with_connection do
          delete(query_from_key(key))
        end
      end

      def delete(query)
        with_connection do
          sql_query = query_builder.build_delete(query)
          query_executor.execute_mutation(sql_query)
          nil
        end
      end

      def count(query)
        with_connection do
          sql_query = query_builder.build_count(query)
          results = query_executor.execute_query(sql_query)
          db_strategy.process_count_result(results[0])
        end
      end

      private

      attr_reader :query_builder, :query_executor, :db_strategy

      def with_connection
        Sql.with_connection(@connection_url) do
          yield
        end
      end

      def non_empty_record?(record)
        record = record.dup
        record.delete(:kind)
        record.delete(:key)
        !record.empty?
      end

      def execute_save_query(sql_query, record)
        result = query_executor.execute_write(sql_query)
        returned_record = db_strategy.process_result(record, result)
        record_from_db(returned_record, record[:kind])
      end

      def record_from_db(record, table)
        record[:key] = Key.compose_key(table, record.delete('id')) if Hyperion.new?(record)
        record[:kind] = table
        record
      end

      def query_from_key(key)
        table, id = Key.decompose_key(key)
        Query.new(table, [Filter.new(:id, '=', id)], nil, nil, nil)
      end
    end
  end
end

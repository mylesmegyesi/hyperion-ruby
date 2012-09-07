require 'hyperion/core'
require 'hyperion/sql/connection'
require 'hyperion/sql/key'
require 'hyperion/sql/query_builder'
require 'hyperion/sql/query_executor'

module Hyperion
  module Sql

    class Datastore

      def initialize(db_strategy, query_executor_strategy, query_builder_strategy)
        @db_strategy = db_strategy
        @query_executor = QueryExecutor.new(query_executor_strategy)
        @query_builder = QueryBuilder.new(query_builder_strategy)
      end

      def save(records)
        records.map do |record|
          sql_query = Core.new?(record) ? query_builder.build_insert(record) : query_builder.build_update(record)
          result = query_executor.execute_write(sql_query)
          returned_record = db_strategy.process_result(record, result)
          record_from_db(returned_record, record[:kind])
        end
      end

      def find_by_key(key)
        find(query_from_key(key)).first
      end

      def find(query)
        sql_query = query_builder.build_select(query)
        results = query_executor.execute_query(sql_query)
        results.map { |record| record_from_db(record, query.kind) }
      end

      def delete_by_key(key)
        delete(query_from_key(key))
      end

      def delete(query)
        sql_query = query_builder.build_delete(query)
        query_executor.execute_mutation(sql_query)
        nil
      end

      def count(query)
        sql_query = query_builder.build_count(query)
        results = query_executor.execute_query(sql_query)
        db_strategy.process_count_result(results[0])
      end

      private

      attr_reader :query_builder, :query_executor, :db_strategy

      def record_from_db(record, table)
        record[:key] = Key.compose_key(table, record.delete('id')) if Core.new?(record)
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

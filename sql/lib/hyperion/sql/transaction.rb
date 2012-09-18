require 'uuidtools'

module Hyperion
  module Sql
    class Transaction

      attr_reader :connection

      def initialize(connection)
        @connection = connection
      end

      def begin
        run "BEGIN"
      end

      def commit
        run "COMMIT"
      end

      def rollback
        run "ROLLBACK"
      end

      def begin_savepoint
        id = new_savepoint_id
        run %{SAVEPOINT "#{id}"}
        id
      end

      def release_savepoint(id)
        run %{RELEASE SAVEPOINT "#{id}"}
      end

      def rollback_to_savepoint(id)
        run %{ROLLBACK TO SAVEPOINT "#{id}"}
      end

      private

      def run(cmd)
        connection.create_command(cmd).execute_non_query
      end

      def new_savepoint_id
        UUIDTools::UUID.random_create.to_s.gsub(/-/, '')
      end
    end
  end
end

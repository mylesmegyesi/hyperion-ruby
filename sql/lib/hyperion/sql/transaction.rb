require 'socket'
require 'digest'
require 'digest/sha2'

module Hyperion
  module Sql
    class Transaction

      HOST = "#{Socket::gethostbyname(Socket::gethostname)[0]}" rescue "localhost"

      attr_reader :connection

      @@counter = 0

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
        Digest::SHA256.hexdigest("#{HOST}:#{$$}:#{Time.now.to_f}:#{@@counter += 1}")[0..-2]
      end
    end
  end
end

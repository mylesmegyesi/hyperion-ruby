require 'data_objects'
require 'hyperion'
require 'hyperion/sql/transaction'
require 'hyperion/util'

module Hyperion
  module Sql

    def self.with_connection(url)
      if Thread.current[:connection]
        yield
      else
        connection = DataObjects::Connection.new(url)
        begin
          Util.bind(:connection, connection) do
            yield
          end
        ensure
          connection.close
        end
      end
    end

    def self.connection
      Thread.current[:connection] || raise('No Connection Established')
    end

    def self.rollback
      with_txn do |txn|
        savepoint_id = txn.begin_savepoint
        begin
          yield
        ensure
          txn.rollback_to_savepoint(savepoint_id)
        end
      end
    end

    def self.transaction
      with_txn do |txn|
        savepoint_id = txn.begin_savepoint
        begin
          result = yield
          txn.release_savepoint(savepoint_id)
          result
        rescue Exception => e
          txn.rollback_to_savepoint(savepoint_id)
          raise e
        end
      end
    end

    private

    def self.with_txn
      if Thread.current[:transaction]
        yield(Thread.current[:transaction])
      else
        txn = Transaction.new(connection)
        Util.bind(:transaction, txn) do
          txn.begin
          result = yield(txn)
          txn.commit
          result
        end
      end
    rescue Exception => e
      txn.rollback
      raise e
    end
  end
end

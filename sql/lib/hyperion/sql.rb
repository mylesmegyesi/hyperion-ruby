require 'hyperion/sql/transaction'

module Hyperion
  module Sql

    def self.with_connection(url)
      connection = DataObjects::Connection.new(url)
      Thread.current[:connection] = connection
      yield(connection)
      connection.close
      Thread.current[:connection] = nil
    end

    def self.connection
      Thread.current[:connection] || raise('No Connection Established')
    end

    def self.rollback
      with_txn do |txn|
        begin
          savepoint_id = txn.begin_savepoint
          yield
        ensure
          txn.rollback_to_savepoint(savepoint_id)
        end
      end
    end

    def self.transaction
      with_txn do |txn|
        begin
          savepoint_id = txn.begin_savepoint
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

    def self.in_transaction?
      !Thread.current[:transaction].nil?
    end

    def self.with_txn
      if Thread.current[:transaction]
        yield(Thread.current[:transaction])
      else
        txn = (Thread.current[:transaction] = Transaction.new(connection))
        txn.begin
        result = yield(txn)
        txn.commit
        result
      end
    rescue Exception => e
      txn.rollback
      raise e
    ensure
      Thread.current[:transaction] = nil
    end
  end
end

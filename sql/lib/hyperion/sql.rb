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
      txn = DataObjects::Transaction.new(nil, connection)
      txn.begin
      yield
      txn.rollback
    end

    def self.transaction
      txn = DataObjects::Transaction.new(nil, connection)
      if Thread.current[:in_transaction]
        yield
      else
        begin
          Thread.current[:in_transaction] = true
          txn.begin
          yield
          txn.commit
        rescue
          txn.rollback
        ensure
          Thread.current[:in_transaction] = false
        end
      end
    end
  end
end

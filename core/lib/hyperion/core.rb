require 'hyperion/query'

module Hyperion
  class Core

    class << self

      attr_writer :datastore

      def datastore
        @datastore || raise('No Datastore installed')
      end

      def save(record, attrs={})
        record = format(record)
        datastore.save([record]).first
      end

      def save_many(records)
        formatted_records = records.map {|record| format(record)}
        datastore.save(formatted_records)
      end

      def new?(record)
        !record.has_key?(:key)
      end

      def find_by_kind(kind, args={})
        query = Query.new(kind)
        datastore.find(query)
      end

      private

      def format(record)
        record[:kind] = record[:kind].to_s
        record
      end

    end
  end
end

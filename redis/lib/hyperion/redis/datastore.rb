require 'hyperion'
require 'hyperion/key'
require 'hyperion/memory/helper'
require 'redis'

module Hyperion
  module Redis
    class Datastore
      def initialize(opts)
        @client = ::Redis.new(opts)
      end

      def save(records)
        records.map do |record|
          Hyperion.new?(record) ? create(record) : update(record)
        end
      end

      def find_by_key(key)
        deserialize(@client.get(key))
      end

      def find(query)
        records = find_by_kind(query.kind)
        records = records.map { |record| deserialize(record) }
        records = Hyperion::Memory::Helper.apply_filters(query.filters, records)
        records = Hyperion::Memory::Helper.apply_sorts(query.sorts, records)
        records = Hyperion::Memory::Helper.apply_offset(query.offset, records)
        records = Hyperion::Memory::Helper.apply_limit(query.limit, records)
        records
      end

      def delete_by_key(key)
        @client.del(key)
        nil
      end

      def delete(query)
        find(query).each { |record| delete_by_key(record[:key]) }
        nil
      end

      def count(query)
        find(query).count
      end

      def pack_key(kind, key)
        key
      end

      def unpack_key(kind, key)
        key
      end

      private

      def create(record)
        kind = record[:kind]
        key = Hyperion::Key.generate_id
        record[:key] = "#{kind}:#{key}"
        persist_record(record)
        record
      end

      def update(record)
        persist_record(record)
        record
      end

      def persist_record(record)
        key = record[:key]
        @client.set(key, serialize(record))
      end

      def find_by_kind(kind)
        keys = @client.keys "#{kind}:*"
        @client.multi do
          keys.each { |key| @client.get key }
        end
      end

      def serialize(record)
        Marshal.dump(record)
      end

      def deserialize(raw_record)
        Marshal.load(raw_record)
      end
    end
  end
end

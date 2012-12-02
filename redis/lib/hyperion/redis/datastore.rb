require 'hyperion'
require 'hyperion/key'
require 'hyperion/memory/helper'
require 'redis'
require 'json'

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
        record = @client.hgetall(key)
        metarecord = @client.hgetall(meta_key(key))
        cast_record(record, metarecord)
      end

      def find(query)
        raw_records = find_by_kind(query.kind)
        records = raw_records.map { |(record, metarecord)| cast_record(record, metarecord) }
        records = Hyperion::Memory::Helper.apply_filters(query.filters, records)
        records = Hyperion::Memory::Helper.apply_sorts(query.sorts, records)
        records = Hyperion::Memory::Helper.apply_offset(query.offset, records)
        records = Hyperion::Memory::Helper.apply_limit(query.limit, records)
        records
      end

      def delete_by_key(key)
        @client.multi do
          @client.del(key)
          @client.del(meta_key(key))
        end
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
        json_record = record.reduce({}) do |acc, (key, val)|
          if val.class == Hash || val.class == Array
            acc[key] = JSON.dump(val)
          else
            acc[key] = val
          end
          acc
        end
        @client.multi do
          @client.hmset(key, *json_record.to_a.flatten)
          @client.hmset(meta_key(key), *meta_record(record).to_a.flatten)
        end
      end

      def find_by_kind(kind)
        keys = @client.keys "#{kind}:*"
        @client.multi do
          keys.each do |key|
            @client.hgetall(key)
            @client.hgetall(meta_key(key))
          end
        end.each_slice(2).to_a
      end

      def meta_record(record)
        record.reduce({}) do |acc, (key, val)|
          acc[key] = to_db_type(val)
          acc
        end
      end

      def meta_key(key)
        "__metadata__" + key
      end

      def cast_record(record, metarecord)
        record.reduce({}) do |acc, (key, value)|
          type = metarecord[key]
          acc[key.to_sym] = from_db_type(value, type)
          acc
        end
      end

      def to_db_type(value)
        if value.class.to_s == "String"
          "String"
        elsif value.class.to_s == "Fixnum"
          "Integer"
        elsif value.class.to_s == "Float"
          "Number"
        elsif value.class.to_s == "TrueClass" || value.class.to_s == "FalseClass"
          "Boolean"
        elsif value.class.to_s == "NilClass"
          "Null"
        elsif value.class.to_s == "Array"
          "Array"
        elsif value.class.to_s == "Hash"
          "Object"
        else
          "Any"
        end
      end

      def from_db_type(value, type)
        if type == "String"
          value
        elsif type == "Integer"
          value.to_i
        elsif type == "Number"
          value.to_f
        elsif type == "Boolean"
          value == 'true' ? true : false
        elsif type == "Null"
          nil
        elsif type == "Array"
          JSON.load(value)
        elsif type == "Object"
          JSON.load(value)
        elsif type == "Any"
          value
        end
      end
    end
  end
end

require 'hyperion'
require 'hyperion/key'
require 'hyperion/memory/helper'

module Hyperion
  class Memory

    def initialize(opts={})
      @store = {}
    end

    def save(records)
      records.map do |record|
        key = Hyperion.new?(record) ? generate_key : record[:key]
        record[:key] = key
        store[key] = record
        record
      end
    end

    def find_by_key(key)
      store[key]
    end

    def find(query)
      records = store.values
      records = filter_kind(query.kind,      records)
      records = Helper.apply_filters(query.filters, records)
      records = Helper.apply_sorts(query.sorts,     records)
      records = Helper.apply_offset(query.offset,   records)
      records = Helper.apply_limit(query.limit,     records)
      records
    end

    def delete_by_key(key)
      store.delete(key)
      nil
    end

    def delete(query)
      records = find(query)
      store.delete_if do |key, record|
        records.include?(record)
      end
      nil
    end

    def count(query)
      find(query).length
    end

    def pack_key(kind, key)
      key
    end

    def unpack_key(kind, key)
      key
    end

    private

    attr_reader :store

    def filter_kind(kind, records)
      records.select do |record|
        record[:kind] == kind
      end
    end

    def generate_key
      Hyperion::Key.generate_id
    end
  end
end

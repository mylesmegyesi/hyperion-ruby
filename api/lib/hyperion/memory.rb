require 'hyperion'
require 'hyperion/key'

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
      records = apply_filters(query.filters, records)
      records = apply_sorts(query.sorts,     records)
      records = apply_offset(query.offset,   records)
      records = apply_limit(query.limit,     records)
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

    def apply_filters(filters, records)
      records.select do |record|
        filters.all? do |filter|
          value = record[filter.field]
          case filter.operator
          when '<'; value < filter.value
          when '<='; value <= filter.value
          when '>'; value > filter.value
          when '>='; value >= filter.value
          when '='; value == filter.value
          when '!='; value != filter.value
          when 'contains?'; filter.value.include?(value)
          end
        end
      end
    end

    def apply_sorts(sorts, records)
      records.sort { |record1, record2| compare_records record1, record2, sorts }
    end

    def compare_records(record1, record2, sorts)
      sorts.each do |sort|
        result = compare_record record1, record2, sort
        return result if result
      end
      0
    end

    def compare_record(record1, record2, sort)
      field1, field2 = record1[sort.field], record2[sort.field]
      field1 == field2                      ?  nil :
        field1 < field2 && sort.ascending?  ?  -1  :
        field1 > field2 && sort.descending? ?  -1  : 1
    end

    def generate_key
      Hyperion::Key.generate_id
    end

    def apply_offset(offset, records)
      return records unless offset
      records.drop offset
    end

    def apply_limit(limit, records)
      return records unless limit
      records.take(limit)
    end
  end
end

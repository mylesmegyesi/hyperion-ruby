module Hyperion
  class Memory
    module Helper
      def self.apply_filters(filters, records)
        records.select do |record|
          filters.all? do |filter|
            value = record[filter.field]
            case filter.operator
            when '<'; value && value < filter.value
            when '<='; value && value <= filter.value
            when '>'; value && value > filter.value
            when '>='; value && value >= filter.value
            when '='; value == filter.value
            when '!='; value != filter.value
            when 'contains?'; filter.value.include?(value)
            when 'like?';  value =~ filter.value
            end
          end
        end
      end

      def self.apply_sorts(sorts, records)
        records.sort { |record1, record2| compare_records record1, record2, sorts }
      end

      def self.compare_records(record1, record2, sorts)
        sorts.each do |sort|
          result = compare_record record1, record2, sort
          return result if result
        end
        0
      end

      def self.compare_record(record1, record2, sort)
        field1, field2 = record1[sort.field], record2[sort.field]
        field1 == field2                      ?  nil :
          field1 < field2 && sort.ascending?  ?  -1  :
          field1 > field2 && sort.descending? ?  -1  : 1
      end

      def self.apply_offset(offset, records)
        return records unless offset
        records.drop offset
      end

      def self.apply_limit(limit, records)
        return records unless limit
        records.take(limit)
      end
    end
  end
end


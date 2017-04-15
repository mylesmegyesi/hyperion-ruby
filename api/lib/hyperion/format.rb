require 'hyperion/util'

module Hyperion
  class Format

    class << self

      def format_kind(kind)
        Util.snake_case(kind.to_s)
      end

      def format_field(field)
        field.to_sym
      end

      def format_record(record)
        record = record.reduce({}) do |new_record, (field_name, value)|
          new_record[format_field(field_name)] = value
          new_record
        end
        record[:kind] = format_kind(record[:kind])
        record
      end

      def format_order(order)
        order.to_sym
        case order
        when :desc, 'desc', 'descending'
          :desc
        when :asc, 'asc', 'ascending'
          :asc
        end
      end

      def format_operator(operator)
        case operator
        when '=', 'eq'
          '='
        when '!=', 'not'
          '!='
        when '<', 'lt'
          '<'
        when '>', 'gt'
          '>'
        when '<=', 'lte'
          '<='
        when '>=', 'gte'
          '>='
        when 'contains?', 'contains', 'in?', 'in'
          'contains?'
        when 'like?', 'like', "~="
          'like?'
        end
      end

    end
  end
end


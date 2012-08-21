require 'hyperion/query'
require 'hyperion/filter'

module Hyperion
  class Core

    class << self

      attr_writer :datastore

      def datastore
        @datastore || raise('No Datastore installed')
      end

      def save(record, attrs={})
        save_many([record.merge(attrs || {})]).first
      end

      def save_many(records)
        format(datastore.save(format(records)))
      end

      def new?(record)
        !record.has_key?(:key)
      end

      def find_by_kind(kind, args={})
        kind = snake_case(kind.to_s)
        filters = build_filters(args[:filters])
        query = Query.new(kind, filters)
        datastore.find(query)
      end

      private

      def build_filters(filters)
        (filters || []).map do |(field, operator, value)|
          operator = parse_operator(operator)
          field = format_field(field)
          Filter.new(field, operator, value)
        end
      end

      def parse_operator(operator)
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
        end
      end

      def format(records)
        records.map do |record|
          record = record.reduce({}) do |new_record, (key, value)|
            snake_case_attr = snake_case(key.to_s)
            new_record[snake_case_attr.to_sym] = value
            new_record
          end
          record[:kind] = record[:kind].to_s
          record
        end
      end

      def format_field(field)
        snake_case(field.to_s).to_sym
      end

      def snake_case(str)
        separate_camel_humps = str.gsub(/([a-z0-9])([A-Z])/, '\1 \2').downcase
        separate_camel_humps.gsub(/[ |\-]/, '_')
      end

    end
  end
end

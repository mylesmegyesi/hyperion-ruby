require 'hyperion/query'
require 'hyperion/filter'
require 'hyperion/sort'

module Hyperion
  class API

    class << self

      attr_writer :datastore

      def datastore=(datastore)
        Thread.current[:datastore] = datastore
      end

      def datastore
        Thread.current[:datastore] || raise('No Datastore installed')
      end

      def save(record, attrs={})
        save_many([record.merge(attrs || {})]).first
      end

      def save_many(records)
        format_records(datastore.save(format_records(records)))
      end

      def new?(record)
        !record.has_key?(:key)
      end

      def find_by_key(key)
        format_record(datastore.find_by_key(key))
      end

      def find_by_kind(kind, args={})
        format_records(datastore.find(build_query(kind, args)))
      end

      def delete_by_key(key)
        datastore.delete_by_key(key)
      end

      def delete_by_kind(kind, args={})
        datastore.delete(build_query(kind, args))
      end

      def count_by_kind(kind, args={})
        datastore.count(build_query(kind, args))
      end

      private

      def build_query(kind, args)
        kind = format_kind(kind)
        filters = build_filters(args[:filters])
        sorts = build_sorts(args[:sorts])
        Query.new(kind, filters, sorts, args[:limit], args[:offset])
      end

      def build_filters(filters)
        (filters || []).map do |(field, operator, value)|
          operator = format_operator(operator)
          field = format_field(field)
          Filter.new(field, operator, value)
        end
      end

      def build_sorts(sorts)
        (sorts || []).map do |(field, order)|
          field = format_field(field)
          order = format_order(order)
          Sort.new(field, order)
        end
      end

      def format_order(order)
        order.to_sym
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
        end
      end

      def format_records(records)
        records.map do |record|
          format_record(record)
        end
      end

      def format_record(record)
        if record
          record = record.reduce({}) do |new_record, (key, value)|
            new_record[snake_case(key.to_s).to_sym] = value
            new_record
          end
          record[:kind] = format_kind(record[:kind])
          record
        end
      end

      def format_kind(kind)
        snake_case(kind.to_s)
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

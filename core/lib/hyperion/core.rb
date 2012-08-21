require 'hyperion/query'

module Hyperion
  class Core

    class << self

      attr_writer :datastore

      def datastore
        @datastore || raise('No Datastore installed')
      end

      def save(record, attrs={})
        attrs ||= {}
        save_many([record.merge(attrs)]).first
      end

      def save_many(records)
        format(datastore.save(format(records)))
      end

      def new?(record)
        !record.has_key?(:key)
      end

      def find_by_kind(kind, args={})
        query = Query.new(kind)
        datastore.find(query)
      end

      private

      def format(records)
        records.map do |record|
          record = record.reduce({}) do |new_record, (key, value)|
            snake_case_attr = snake_case(key.to_s)
            new_record[snake_case_attr.to_sym] = value
            new_record
          end
          kind_to_string(record)
        end
      end

      def snake_case(str)
        separate_camel_humps = str.gsub(/([a-z0-9])([A-Z])/, '\1 \2').downcase
        separate_camel_humps.gsub(/[ |\-]/, '_')
      end

      def kind_to_string(record)
        record[:kind] = record[:kind].to_s
        record
      end

    end
  end
end

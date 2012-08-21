require 'hyperion/core'

module Hyperion
  module Dev
    class Memory

      def initialize
        @id_counter = 0
        @store = {}
      end

      def save(records)
        records.map do |record|
          key = Core.new?(record) ? generate_key : record[:key]
          record[:key] = key
          store[key] = record
          record
        end
      end

      def find(query)
        store.values.select do |record|
          record[:kind] == query.kind
        end
      end

      private

      attr_accessor :store

      def generate_key
        @id_counter += 1
        @id_counter
      end

    end
  end
end

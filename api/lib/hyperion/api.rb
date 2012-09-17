require 'hyperion/query'
require 'hyperion/filter'
require 'hyperion/sort'
require 'hyperion/util'

module Hyperion
  class API

    class << self

      attr_writer :datastore

      # Sets the thread-local active datastore
      def datastore=(datastore)
        Thread.current[:datastore] = datastore
      end

      # Returns the current thread-local datastore instance
      def datastore
        Thread.current[:datastore] || raise('No Datastore installed')
      end

      # Assigns the datastore within the given block
      def with_datastore(name, opts={})
        self.datastore = new_datastore(name, opts)
        yield
        self.datastore = nil
      end

      def new_datastore(name, opts={})
        begin
          require "hyperion/#{name}"
        rescue LoadError
          raise "Can't find datastore implementation: #{name}"
        end
        ds_klass = Hyperion.const_get(Util.class_name(name.to_s))
        ds_klass.new(opts)
      end

      #   Saves a record. Any additional parameters will get merged onto the record before it is saved.

      #  Hyperion::API.save({:kind => :foo})
      #  => {:kind=>"foo", :key=>"<generated key>"}
      #  Hyperion::API.save({:kind => :foo}, :value => :bar)
      #  => {:kind=>"foo", :value=>:bar, :key=>"<generated key>"}
      def save(record, attrs={})
        save_many([record.merge(attrs || {})]).first
      end

      # Saves multiple records at once.
      def save_many(records)
        format_records(datastore.save(format_records(records)))
      end

      # Returns true if the record is new (not saved/doesn't have a :key), false otherwise.
      def new?(record)
        !record.has_key?(:key)
      end

      # Retrieves the value associated with the given key from the datastore. nil if it doesn't exist.
      def find_by_key(key)
        format_record(datastore.find_by_key(key))
      end

      # Returns all records of the specified kind that match the filters provided.
      #
      #   find_by_kind(:dog) # returns all records with :kind of \"dog\"
      #   find_by_kind(:dog, :filters => [[:name, '=', "Fido"]]) # returns all dogs whos name is Fido
      #   find_by_kind(:dog, :filters => [[:age, '>', 2], [:age, '<', 5]]) # returns all dogs between the age of 2 and 5 (exclusive)
      #   find_by_kind(:dog, :sorts => [[:name, :asc]]) # returns all dogs in alphebetical order of their name
      #   find_by_kind(:dog, :sorts => [[:age, :desc], [:name, :asc]]) # returns all dogs ordered from oldest to youngest, and gos of the same age ordered by name
      #   find_by_kind(:dog, :limit => 10) # returns upto 10 dogs in undefined order
      #   find_by_kind(:dog, :sorts => [[:name, :asc]], :limit => 10) # returns upto the first 10 dogs in alphebetical order of their name
      #   find_by_kind(:dog, :sorts => [[:name, :asc]], :limit => 10, :offset => 10) # returns the second set of 10 dogs in alphebetical order of their name
      #
      # Filter operations and acceptable syntax:
      #   "=" "eq"
      #   "<" "lt"
      #   "<=" "lte"
      #   ">" "gt"
      #   ">=" "gte"
      #   "!=" "not"
      #   "contains?" "contains" "in?" "in"
      #
      # Sort orders and acceptable syntax:
      #   :asc "asc" :ascending "ascending"
      #   :desc "desc" :descending "descending"
      def find_by_kind(kind, args={})
        format_records(datastore.find(build_query(kind, args)))
      end

      # Removes the record stored with the given key. Returns nil no matter what.
      def delete_by_key(key)
        datastore.delete_by_key(key)
      end

      # Deletes all records of the specified kind that match the filters provided.
      def delete_by_kind(kind, args={})
        datastore.delete(build_query(kind, args))
      end

      # Counts records of the specified kind that match the filters provided.
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

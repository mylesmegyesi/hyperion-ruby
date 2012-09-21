require 'hyperion'
require 'hyperion/key'
require 'hyperion/riak/map_reduce_javascript'
require 'riak'

module Hyperion
  module Riak
    class Datastore
      def initialize(opts={})
        opts ||= {}
        @app = opts[:app]
        client_options = opts.reject {|k, v| k == :app}
        @client = ::Riak::Client.new(client_options)
        @buckets = {}
      end

      def save(records)
        records.map do |record|
          kind = record[:kind]
          if Hyperion.new?(record)
            record = record_to_db(record)
            robject = bucket(kind).new
            robject.data = record
            robject.store
            record_from_db(kind, robject.key, robject.data)
          else
            kind, riak_key = Hyperion::Key.decompose_key(record[:key])
            record = record_to_db(record)
            robject = bucket(kind).get(riak_key)
            robject.data = robject.data.merge(record)
            robject.store
            record_from_db(kind, robject.key, robject.data)
          end
        end
      end

      def find_by_key(key)
        kind, riak_key = Hyperion::Key.decompose_key(key)
        load_riak_key(bucket(kind), kind, riak_key)
      end

      def find(query)
        mr = new_mapreduce_with_return(query)
        mr.run.map do |record|
          record_from_db(query.kind, record['riak_key'], record.merge('riak_key' => nil))
        end
      end

      def delete_by_key(key)
        kind, riak_key = Hyperion::Key.decompose_key(key)
        delete_with_riak_key(kind, riak_key)
        nil
      end

      def delete(query)
        mr = new_mapreduce_with_return(query)
        mr.run.each do |record|
          delete_with_riak_key(query.kind, record['riak_key'])
        end
        nil
      end

      def count(query)
        mr = new_mapreduce(query)
        mr.reduce(COUNT_REDUCTION, :keep => true)
        mr.run.first
      end

      private

      def delete_with_riak_key(kind, key)
        bucket(kind).delete(key)
      end

      def new_mapreduce(query)
        mr = ::Riak::MapReduce.new(@client).add(bucket_name(query.kind)).map(VALUE_MAP)
        query.filters.each {|filter| mr.reduce(FILTER_REDUCTION, :arg => filter.to_h)}
        sorts = query.sorts
        mr.reduce(SORT_REDUCTION, :arg => sorts.map(&:to_h)) unless sorts.empty?
        mr.reduce(OFFSET_REDUCTION, :arg => query.offset) if query.offset
        mr.reduce(LIMIT_REDUCTION, :arg => query.limit) if query.limit
        mr
      end

      def new_mapreduce_with_return(query)
        mr = new_mapreduce(query)
        mr.reduce(PASS_THRU_REDUCTION, :keep => true)
      end

      def load_riak_key(bucket, kind, key)
        robject = bucket.get(key)
        record_from_db(kind, robject.key, robject.data)
      end

      def record_to_db(record)
        record.dup
        record.delete(:kind)
        record.delete(:key)
        record
      end

      def record_from_db(kind, riak_key, data)
        key = Hyperion::Key.compose_key(kind, riak_key)
        data.merge(:kind => kind, :key => key)
      end

      def bucket(kind)
        name = bucket_name(kind)
        @buckets[name] ||= @client.bucket(name)
      end

      def bucket_name(kind)
        @app.to_s + kind
      end
    end
  end
end

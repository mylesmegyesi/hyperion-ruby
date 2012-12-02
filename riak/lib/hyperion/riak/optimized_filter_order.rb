require 'hyperion/riak/optimized_range_filters'

module Hyperion
  module Riak
    class OptimizedFilterOrder

      def initialize(filters, bucket_name)
        @bucket_name = bucket_name
        @filters = filters
      end

      def optimal_strategy
        @optimal_strategy ||= OPTIMAL_ORDER.map do |strategy_klass|
          strategy_klass.new(@filters, @bucket_name)
        end.find do |strategy|
          strategy.can_optimize?
        end
      end

      def optimal_index_field
        optimal_strategy.optimal_index_field
      end

      def optimal_index_value
        optimal_strategy.optimal_index_value
      end

      def filters
        optimal_strategy.filters
      end

      private
    end

    class EqualsStrategy
      def initialize(filters, bucket_name)
        @filters = filters
      end

      def can_optimize?
        !first_equals_filter.nil? && !first_equals_filter.value.nil?
      end

      def optimal_index_field
        first_equals_filter.field
      end

      def optimal_index_value
        first_equals_filter.value.to_s
      end

      def filters
        @remaining_filters ||= (@filters - [first_equals_filter])
      end

      private

      def first_equals_filter
        @first_equals_filter ||= @filters.find { |f| f.operator == "=" }
      end
    end

    class RangeStrategy
      def initialize(filters, bucket_name)
        @filters = filters
        @optimizer = OptimizedRangeFilters.new(filters)
      end

      def can_optimize?
        @optimizer.less_than_filter && @optimizer.greater_than_filter
      end

      def optimal_index_field
        @optimizer.less_than_filter.field
      end

      def optimal_index_value
        @value ||= @optimizer.less_than_filter.value.to_s .. @optimizer.greater_than_filter.value.to_s
      end

      def filters
        @optimizer.remaining_filters
      end
    end

    class BucketStrategy
      def initialize(filters, bucket_name)
        @filters = filters
        @bucket_name = bucket_name
      end

      def can_optimize?
        true
      end

      def optimal_index_field
        '$bucket'
      end

      def optimal_index_value
        @bucket_name
      end

      def filters
        @filters
      end
    end

    OPTIMAL_ORDER = [EqualsStrategy, RangeStrategy, BucketStrategy]
  end
end

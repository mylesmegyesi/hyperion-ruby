module Hyperion
  module Riak
    class OptimizedRangeFilters
      def initialize(filters)
        @filters = filters
      end

      def remaining_filters
        @remaining_filters ||= @filters - [less_than_filter, greater_than_filter]
      end

      def less_than_filter
        @less_than_filter ||= find_first_match(less_than_candidates, greater_than_candidates)
      end

      def greater_than_filter
        @greater_than_filter ||= find_first_match(greater_than_candidates, less_than_candidates)
      end

      private

      def find_first_match(filters_to_search, filters_to_match_against)
        filters_to_search.find do |f1|
          filters_to_match_against.any? { |f2| f1.field == f2.field }
        end
      end

      def greater_than_candidates
        @greater_than_filters ||= @filters.select do |filter|
          filter.operator == '>'
        end
      end

      def less_than_candidates
        @less_than_candidates ||= @filters.select do |filter|
          filter.operator == '<'
        end
      end

    end
  end
end

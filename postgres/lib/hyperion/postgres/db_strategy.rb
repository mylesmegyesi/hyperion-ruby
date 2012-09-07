module Hyperion
  module Postgres
    class DbStrategy

      def process_result(given_record, result)
        result[0]
      end

      def process_count_result(result)
        result['count']
      end

    end
  end
end

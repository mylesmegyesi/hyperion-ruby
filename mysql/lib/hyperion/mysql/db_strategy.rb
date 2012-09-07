require 'hyperion/core'

module Hyperion
  module Mysql
    class DbStrategy

      def process_result(given_record, result)
        if Core.new?(given_record)
          given_record.merge('id' => result.insert_id)
        else
          given_record
        end
      end

      def process_count_result(result)
        result['COUNT(*)']
      end
    end
  end
end

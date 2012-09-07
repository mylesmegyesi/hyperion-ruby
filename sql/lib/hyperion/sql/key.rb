
module Hyperion
  module Sql

    class Key
      def self.compose_key(table, id)
        "#{table}-#{id}"
      end

      def self.decompose_key(key)
        parts = key.rpartition('-')
        [parts.first, parts.last]
      end
    end

  end
end

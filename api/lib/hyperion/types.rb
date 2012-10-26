require 'hyperion'
require 'hyperion/format'

module Hyperion
  class Types
    class << self

      def foreign_key(kind)
        kind_key = "#{Format.format_kind(kind)}_key".to_sym
        unless Hyperion.packer_defined?(kind_key)
          Hyperion.pack(kind_key) do |key|
            Hyperion.datastore.pack_key(kind, key)
          end
          Hyperion.unpack(kind_key) do |key|
            Hyperion.datastore.unpack_key(kind, key)
          end
        end
        kind_key
      end
    end
  end
end

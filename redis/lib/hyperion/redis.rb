require 'hyperion/redis/datastore'

module Hyperion
  module Redis
    def self.new(opts = {})
      Datastore.new(opts)
    end
  end
end

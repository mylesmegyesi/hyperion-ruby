require 'hyperion/dev/ds_spec'
require 'hyperion/redis'
require 'hyperion/redis/spec_helper'

describe Hyperion::Redis do
  with_testable_redis_datastore

  include_examples 'Datastore'
end

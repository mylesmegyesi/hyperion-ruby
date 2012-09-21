require 'hyperion/dev/ds_spec'
require 'hyperion/riak'
require 'hyperion/riak/spec_helper'

describe Hyperion::Riak do

  context 'live' do
    with_testable_riak_datastore

    include_examples 'Datastore'
  end
end

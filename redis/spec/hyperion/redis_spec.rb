require 'hyperion/dev/ds_spec'
require 'hyperion/redis'
require 'hyperion/redis/spec_helper'

describe Hyperion::Redis do
  with_testable_redis_datastore

  include_examples 'Datastore'

  it "persists and pulls out the array type" do
    record = api.save(:kind => "test", :foreign_keys => [1, 2, 3])
    found_record = api.find_by_key(record[:key])
    found_record[:foreign_keys].should == [1, 2, 3]
  end

  it "persists and pulls out the hash type" do
    record = api.save(:kind => "test", :map => {"some_id" => 1, "some_other_id" => 2})
    found_record = api.find_by_key(record[:key])
    found_record[:map]["some_id"].should == 1
    found_record[:map]["some_other_id"].should == 2
  end

  it "returns nil for a not found key" do
    api.find_by_key("notreal").should be_nil
  end
end

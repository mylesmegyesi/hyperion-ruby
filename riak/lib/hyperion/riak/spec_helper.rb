def test_app_name
  '_HTEST_'
end

BUCKETS = ['testing', 'other_testing', 'account', 'shirt']

def empty_buckets(ds)
  old = Riak.disable_list_keys_warnings
  Riak.disable_list_keys_warnings = true
  client = ds.instance_variable_get(:@client)
  BUCKETS.each do |bucket_name|
    bucket_name = ds.send(:bucket_name, bucket_name)
    bucket = client.bucket(bucket_name)
    bucket.keys.each {|k| bucket.delete(k) }
  end
  Riak.disable_list_keys_warnings = old
end

def with_testable_riak_datastore
  ds = Hyperion.new_datastore(:riak, :app => test_app_name, :protocol => :pbc)
  around :each do |example|
    Hyperion.datastore = ds
    example.run
    empty_buckets(ds)
    Hyperion.datastore = nil
  end
end

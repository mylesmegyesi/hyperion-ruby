def test_app_name
  '_HTEST_'
end

BUCKETS = ['testing', 'other_testing']

def empty_buckets
  client = ::Riak::Client.new(:protocol => :pbc)
  BUCKETS.each do |bucket_name|
    bucket_name = test_app_name + bucket_name
    bucket = client.bucket(bucket_name)
    bucket.get_index('$bucket', bucket_name).each do |key|
      bucket.delete(key)
    end
  end
end

def with_testable_riak_datastore
  around :each do |example|
    Hyperion.with_datastore(:riak, :app => test_app_name, :protocol => :pbc) do
      example.run
      empty_buckets
    end
  end
end

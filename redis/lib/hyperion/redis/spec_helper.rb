def clear_keys(ds)
  client = ds.instance_variable_get(:@client)
  keys = client.keys("*")
  keys.each { |key| client.del key }
end

def with_testable_redis_datastore
  ds = Hyperion.new_datastore(:redis)
  around :each do |example|
    Hyperion.datastore = ds
    example.run
    clear_keys(ds)
    Hyperion.datastore = nil
  end
end
